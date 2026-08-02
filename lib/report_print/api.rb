module ReportPrint
  ##
  # These are the extensions that are included into the Module class that
  # enabled you to customize the behaviour of ReportPrint for your own classes.
  module Api
    ##
    # Defines options used by the printer when printing instances of the
    # current class.
    #
    # The currently supported options are:
    #
    # * `detect_cycles:` whether instances of this class should display just a
    #   header and id when printed multiple times by the same report print
    #   command.
    #   <br>
    #   Defaults to `true` except for in the case of the simple value types and
    #   Data classes.
    # * `color:` the color value to apply when using #report_print_inspect!.
    #   <br>
    #   Defaults to `nil`.
    #
    # #### Example Usage
    #
    # ```
    # class WithColor
    #   report_print_options(color: :bright_blue)
    #   report_print_inspect!
    # end
    #
    # class CustomContainer
    #   report_print_options(detect_cycles: false)
    # end
    # ```
    #
    # #### Option Loading
    #
    # Setting any value to `nil` means: take the global value if it is defined.
    #
    # When ReportPrint fetches options for a given class it first fetches the
    # superclass options (recursively), then it merges the options for the
    # current class on top.
    #
    # After which it compacts the options (removing the nils) and merges them
    # on top of any global options. Where the global options are currently
    # specified by calling `ReportPrint.report_print_options`.
    def report_print_options(**kwargs)
      @report_print_options = (@report_print_options || {}).merge(kwargs)
    end

    ##
    # Helper that defines a `report_print` method which calls `inspect` and
    # applies the `color:` specified in #report_print_options.
    def report_print_inspect!
      define_method(:report_print) do |rp|
        rp.write(inspect, color: rp.options_for(self)[:color])
      end
    end
  end
end

Module.prepend(ReportPrint::Api)
