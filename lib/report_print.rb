require_relative "report_print/version"
require_relative "report_print/printer"
require_relative "report_print/core_extensions"

module ReportPrint
  class Error < StandardError; end
  # Your code goes here...
end

include ReportPrint::CoreExtensions
