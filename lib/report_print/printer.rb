require "rainbow"

module ReportPrint
  class Printer
    State = Data.define(
      :mode,
      :indent,
      :separator,
      :inline_separator,
      :next_inline_separator,
      :after,
      :start_of_line,
      :start_of_block
    ) do
      def inline?
        mode == :inline
      end
    end

    def initialize(output = $>, color: :auto)
      @output = output
      if color == :auto
        color = output.respond_to?(:tty?) && output.tty?
      end
      @rainbow = Rainbow::Wrapper.new(color)

      @seen = ::Set.new
      @state = State[
        mode: :multiline,
        indent: 0,
        separator: "",
        inline_separator: "",
        next_inline_separator: nil,
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
        write("BasicObject", color: :bright_yellow)
      end
    end

    def color(input, *values)
      wrapped = @rainbow.wrap(input.to_s)
      case values
      in [Symbol => name]
        if (matches = name.match(/bright_(\w+)/))
          wrapped.color(matches[1].to_sym).bright
        else
          wrapped.color(name)
        end
      in []
        wrapped
      else
        wrapped.color(*values)
      end
    end

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
        if @state.next_inline_separator != result.next_inline_separator
          # If the inner inline state is requesting a separator, then that
          # means we should request the current separator instead.
          set_state(next_inline_separator: @state.inline_separator)
        end
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
        next_inline_separator: nil,
        separator:,
        &block
      )

      set_state(
        start_of_block: @state.start_of_block && result.start_of_block
      )

      did_write = !result.start_of_block

      if did_write || after_empty
        unless after.nil?
          multiline(indent: 0) do
            write(after)
          end
          did_write = true
        end
      end

      if did_write
        if @state.inline?
          set_state(next_inline_separator: @state.inline_separator)
        else
          # This is to cleanup the special case handling of the outermost state.
          # Likely this would be more clear with an explicit flag.
          set_state(start_of_line: true)
        end
      end
    end

    def write(*strings, color: nil)
      if @state.start_of_line
        unless @state.start_of_block
          @output.write(@state.separator)
        end
        break_line
      elsif @state.next_inline_separator
        @output.write(@state.next_inline_separator)
      end

      if color
        strings = strings.map do |string|
          self.color(string, *Array(color))
        end
      end

      @output.write(*strings)

      if @state.inline?
        set_state(
          start_of_line: false,
          start_of_block: false,
          next_inline_separator: @state.inline_separator
        )
      else
        set_state(
          start_of_block: false,
          start_of_line: true
        )
      end
    end

    def write_header(object, write_id: true)
      inline(" ") do
        write(object.class.short_class_name, color: :bright_yellow)
        if write_id
          write_object_id(object)
        end
      end
    end

    def write_object_id(object)
      write(sprintf("%#x", object.__id__), color: :bright_black)
    end

    def write_instance_variables(object, variables = :all)
      if variables == :all
        variables = object.instance_variables
      end

      variables.each do |name|
        inline(" ") do
          write(name, color: :bright_cyan)
          write("=")
          rp(object.instance_variable_get(name))
        end
      end
    end

    def unless_seen(object)
      if @seen.include?(object.__id__)
        write_header(object)
      else
        @seen.add(object.__id__)
        yield
      end
    end

    private

    def break_line
      @output.write("\n")
      @output.write(" " * @state.indent)
    end

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
