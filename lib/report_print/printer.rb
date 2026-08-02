require "rainbow"
using ReportPrint::Refinements

module ReportPrint
  ##
  # The class of the printer instances provided to Object#report_print methods.
  class Printer
    State = Data.define( # :nodoc:
      :mode,
      :indent,
      :separator,
      :inline_separator,
      :next_inline_separator,
      :after,
      :start_of_line,
      :start_of_block,
      :start_of_output
    ) do
      def inline?
        mode == :inline
      end
    end

    ##
    # Returns a new printer object writing to the specified `output`.
    #
    # **Intended only for internal use.** See Dsl#rp for more details.
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
        start_of_line: true,
        start_of_block: true,
        start_of_output: true
      ]

      @options = ScopedOptions.new(ReportPrint.report_print_options)
    end

    ##
    # Print an `object` using its Object#report_print method.
    #
    # Note: if an argument is provided which does not inherit from Object, then
    # `"BasicObject"` will be printed.
    def rp(object)
      case object
      when Object
        if @seen.include?(object.__id__)
          object.report_print_cycle(self)
        else
          if options_for(object)[:detect_cycles]
            @seen.add(object.__id__)
          end
          object.report_print(self)
        end
      else
        write("BasicObject", color: :bright_yellow)
      end
    end

    ##
    # Wrap the provided input string in a `Rainbow::Presenter` and color it using
    # `Rainbow::Presenter#color` passing the provided values.
    #
    # This uses a `Rainbow::Wrapper` instantiated by the Printer which uses the
    # user specified settings for whether color printing is enabled.
    #
    # Additionally if `values` is a single symbol matching `/bright_(\w+)/`,
    # then it will first apply the specified color, then apply
    # `Rainbow::Presenter#bright` to the output.
    #
    # Thus the following are equivalent:
    #
    # ```
    # rp.color("string", :bright_blue)
    # rp.color("string", :blue).bright
    # ```
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

    ##
    # Define a block which prints each item on the same line separated by
    # `inline_separator`.
    #
    # If called inside another #inline block, it only customize the separator
    # between the elements printed within the block.
    #
    # If no `inline_separator` is specified, then the `inline_separator` of the
    # containing inline block will be used, or `""` if there is no containing
    # inline block.
    #
    # If you want to reset the separator to the empty value you will thus need
    # to pass `nil` or `""`.
    def inline(inline_separator = :inherit, &block)
      if inline_separator == :inherit
        inline_separator = @state.inline_separator
      end
      result = with_state(mode: :inline, inline_separator:, &block)
      if @state.inline?
        set_state(
          start_of_line: @state.start_of_line && result.start_of_line,
          start_of_block: @state.start_of_block && result.start_of_block,
          start_of_output: @state.start_of_output && result.start_of_output
        )
        if @state.next_inline_separator != result.next_inline_separator
          # If the inner inline state is requesting a separator, then that
          # means we should request the current separator instead.
          set_state(next_inline_separator: @state.inline_separator)
        end
      else
        set_state(
          start_of_block: @state.start_of_block && result.start_of_block,
          start_of_output: @state.start_of_output && result.start_of_output
        )
      end
    end

    ##
    # Define a block which prints each item or #inline block on a separate line.
    #
    # Accepts the following options:
    #
    # * `separator:` a separator to print before each newline, or `:inherit` to
    #   use the separator of the containing multiline block.
    # * `after:` a string to print after the end of the block.
    # * `after_empty:` if true, print `after:` even when nothing was written
    #   inside the block.
    # * `indent:` the number of spaces to increase the indent by inside the block.
    def multiline(
      separator: nil,
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
        start_of_block: @state.start_of_block && result.start_of_block,
        start_of_output: @state.start_of_output && result.start_of_output
      )

      did_write = !result.start_of_block

      if did_write || after_empty
        unless after.nil?
          if did_write
            break_line
          end
          @output.write(after)
          set_state(start_of_block: false)

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

    ##
    # Write out the provided `strings` given the current printer state.
    #
    # If `color:` is provided it will be interpreted the same as in the case
    # where #color is given a singular argument.
    #
    # When multiple strings are provided, they will be rendered as if they were
    # first concatenated into a single string, as in `IO#write`. Meaning no
    # separators or line breaks will be rendered between them.
    def write(*strings, color: nil)
      if @state.start_of_line && !@state.start_of_output
        unless @state.start_of_block
          @output.write(@state.separator)
        end
        break_line
      elsif @state.next_inline_separator
        @output.write(@state.next_inline_separator)
      end

      if color
        strings = strings.map do |string|
          self.color(string, color)
        end
      end

      @output.write(*strings)

      if @state.inline?
        set_state(
          start_of_line: false,
          start_of_block: false,
          start_of_output: false,
          next_inline_separator: @state.inline_separator
        )
      else
        set_state(
          start_of_block: false,
          start_of_line: true,
          start_of_output: false
        )
      end
    end

    ##
    # Write the class name and the object id joined with a space.
    #
    # <pre>
    # <span style="color:var(--code-orange)"
    # >Object</span> <span style="color:var(--code-gray)"
    # >0xabcd1234</span>
    # </pre>
    def write_header(object, write_id: true)
      inline(" ") do
        write(object.class.short_class_name, color: :bright_yellow)
        if write_id
          write_object_id(object)
        end
      end
    end

    ##
    # Write the id of the object as hex.
    #
    # <pre>
    # <span style="color:var(--code-gray)">0xabcd1234</span>
    # </pre>
    def write_object_id(object)
      write(sprintf("%#x", object.__id__), color: :bright_black)
    end

    ##
    # Write out the instance variables of an object.
    #
    # If an array of symbols is provided as `variables`, only those will be
    # considered, otherwise all variables returned by Object#instance_variables
    # will be used.
    #
    # ```
    # class Example
    #   def new(value)
    #     @value = value
    #     @string = value.to_s
    #   end
    # end
    #
    # rp.write_instance_variables(Example.new(1))
    # rp.write_instance_variables(Example.new(:two), [:@value])
    # ```
    #
    # Output:
    #
    # <pre>
    # <span style="color:var(--code-cyan)"
    # >@value</span> = <span style="color:var(--code-purple)"
    # >1</span>
    # <span style="color:var(--code-cyan)"
    # >@string</span> = <span style="color:var(--code-green)"
    # >"1"</span>
    # <span style="color:var(--code-cyan)"
    # >@value</span> = <span style="color:var(--code-blue)"
    # >:two</span>
    # </pre>
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

    ##
    # Fetch the options which are set for the class of `object`.
    #
    # See Api#report_print_options for more details about the available
    # options.
    def options_for(object)
      @options.options_for(object.class)
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
