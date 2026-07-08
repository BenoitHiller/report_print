require "rainbow"

module ReportPrint
  module RainbowRefinements
    refine Rainbow::Presenter do
      def color(*values)
        case values
        in [Symbol => name]
          if (matches = name.match(/bright_(\w+)/))
            super(matches[1].to_sym).bright
          else
            super
          end
        else
          super
        end
      end
    end
  end
  using RainbowRefinements

  State = Data.define(
    :mode,
    :indent,
    :separator,
    :inline_separator,
    :after,
    :start_of_line,
    :start_of_block
  ) do
    def inline?
      mode == :inline
    end
  end

  class Printer
    def initialize(output = $>, color: :auto)
      @output = output
      @rainbow = Rainbow.new
      if color == :auto
        @rainbow.enabled = output.respond_to?(:tty?) && output.tty?
      else
        @rainbow.enabled = color
      end

      @seen = ::Set.new
      @state = State[
        mode: :multiline,
        indent: 0,
        separator: "",
        inline_separator: "",
        after: nil,
        start_of_line: false,
        start_of_block: true
      ]
    end

    def rp(object)
      case object
      when Object
        object.report_print
      else
        write("BasicObject")
      end
    end

    def write_object(object, variables = :all)
      unless_seen(object) do
        if variables == :all
          variables = object.instance_variables
        end
        write_header(object)
        multiline(after: Rainbow("end").blue.bright, after_empty: false) do
          variables.each do |name|
            inline(" ") do
              write(name, color: :bright_cyan)
              write("=")
              rp(object.instance_variable_get(name))
            end
          end

          if block_given?
            yield
          end
        end
      end
    end

    # rubocop:disable Naming/MethodName
    def Rainbow(string)
      @rainbow.wrap(string.to_s)
    end
    # rubocop:enable Naming/MethodName

    def inline(inline_separator = :inherit, &block)
      if inline_separator == :inherit
        inline_separator = @state.inline_separator
      end
      result = with_state(mode: :inline, inline_separator:, &block)
      if @state.inline?
        set_state(
          start_of_line: @state.start_of_line && result.start_of_line,
          start_of_block: @state.start_of_block && result.start_of_block
        )
      else
        set_state(
          start_of_block: @state.start_of_block && result.start_of_block
        )
      end
    end

    def multiline(
      separator: :inherit,
      after: nil,
      after_empty: true,
      indent: 2,
      &block
    )
      if separator == :inherit
        separator = @state.separator
      end

      result = with_state(
        mode: :multiline,
        start_of_line: true,
        start_of_block: true,
        indent: @state.indent + indent,
        separator:,
        &block
      )

      set_state(
        start_of_block: @state.start_of_block && result.start_of_block
      )

      if !result.start_of_block || after_empty
        unless after.nil?
          multiline(indent: 0) do
            write(after)
          end
        end
      end
    end

    def write(*strings, color: nil)
      if @state.start_of_line
        unless @state.start_of_block
          @output.write(@state.separator)
        end
        break_line
      else
        @output.write(@state.inline_separator)
      end

      if color
        strings = strings.map do |string|
          Rainbow(string).color(color)
        end
      end

      @output.write(*strings)

      if @state.inline?
        set_state(
          start_of_line: false,
          start_of_block: false
        )
      else
        set_state(
          start_of_block: false
        )
      end
    end

    def write_header(object, write_id: true)
      inline do
        write(object.class.short_class_name, color: :bright_yellow)
        if write_id
          inline(" ") do
            write_object_id(object)
          end
        end
      end
    end

    def write_object_id(object)
      write(sprintf("%#x", object.__id__), color: :bright_black)
    end

    def unless_seen(object)
      if @seen.include?(object.__id__)
        write_header(object)
      else
        @seen.add(object.__id__)
        yield
      end
    end

    def break_line
      @output.write("\n")
      @output.write(" " * @state.indent)
    end

    private

    def with_state(**kwargs)
      previous = @state
      @state = previous.with(**kwargs)

      yield

      result, @state = @state, previous
      result
    end

    def set_state(**kwargs)
      @state = @state.with(**kwargs)
    end
  end
end
