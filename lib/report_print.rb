require_relative "report_print/version"
require_relative "report_print/refinements"
require_relative "report_print/printer"
require_relative "report_print/core_extensions"
require_relative "report_print/dsl"

module ReportPrint; end

Kernel.prepend(ReportPrint::Dsl)
