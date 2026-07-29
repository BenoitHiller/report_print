module ReportPrint
  module Refinements
    refine Object.singleton_class do
      def report_print_inspect!(color: nil)
        define_method(:report_print) do |rp|
          # @type self: Object
          rp.write(inspect, color:)
        end
      end
    end

    refine Module do
      def short_class_name
        name.sub(/^.*::/, "")
      end
    end
  end
end
