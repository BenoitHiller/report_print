module ReportPrint
  module Refinements
    refine Module do
      def short_class_name
        name.sub(/^.*::/, "")
      end
    end
  end
end
