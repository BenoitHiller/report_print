module ReportPrint
  module Dsl
    ##
    # Render out the specified `object` using its Object#report_print method.
    #
    # Arguments:
    #
    # * `output:` specifies where the output should be written to, by default
    #   it is `$>`, meaning standard output.
    # * `color:` specifies whether the text should render colored output or
    #   not. The default value of `:auto` indicates that it should use the
    #   value of `output.tty?` to determine if color output is enabled or not.
    def rp(object, output: $>, color: :auto)
      printer = Printer.new(output, color:)
      printer.rp(object)
      output.write("\n")

      nil
    end
  end
end
