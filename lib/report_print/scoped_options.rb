module ReportPrint
  class ScopedOptions
    def initialize(global_options)
      @global_options = global_options
      @cache = {
        Object => Object.report_print_options,
        BasicObject => {}
      }
    end

    def options_for(klass)
      @global_options.merge(self_options_for(klass).compact)
    end

    private def self_options_for(klass)
      @cache[klass] ||= (
        self_options_for(klass.superclass).merge(klass.report_print_options)
      )
    end
  end
end
