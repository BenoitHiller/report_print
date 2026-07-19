require_relative "report_print/version"
require_relative "report_print/printer"

module ReportPrint
  class Error < StandardError; end
  # Your code goes here...
end

class Object < BasicObject
  class << self
    def report_print_inspect!(color: nil)
      define_method(:report_print) do
        rp.write(inspect, color:)
      end
    end
  end

  def report_print
    rp.unless_seen(self) do
      rp.write_header(self)
      rp.multiline(after: rp.color("end", :bright_blue), after_empty: false) do
        rp.write_instance_variables(self)
      end
    end
  end
end

class Module < Object
  def report_print
    rp.write(short_class_name)
  end

  def short_class_name
    name.sub(/.*::/, "")
  end
end

class Symbol < Object
  report_print_inspect!(color: :bright_cyan)
end

class TrueClass < Object
  report_print_inspect!(color: :bright_blue)
end

class FalseClass < Object
  report_print_inspect!(color: :bright_blue)
end

class Numeric < Object
  report_print_inspect!(color: :bright_magenta)
end

class String < Object
  report_print_inspect!(color: :bright_green)
end

class NilClass < Object
  report_print_inspect!(color: :bright_blue)
end

class Array < Object
  def report_print
    rp.write("[")
    rp.multiline(after: "]", separator: ",") do
      to_a.each do |item|
        rp(item)
      end
    end
  end
end

class Hash < Object
  def report_print
    rp.write("{")
    rp.multiline(after: "}", separator: ",") do
      each do |key, value|
        rp.inline(" ") do
          case key
          in Symbol
            rp.write(key, ":", color: :bright_cyan)
          else
            rp(key)
            rp.write("=>")
          end

          rp(value)
        end
      end
    end
  end
end

class Set < Object
  def report_print
    rp.inline("") do
      rp.write("Set", color: :yellow)
      rp.write("[")
    end
    rp.multiline(after: "]", separator: ",") do
      to_a.each do |item|
        rp(item)
      end
    end
  end
end

class Data < Object
  def report_print
    name = self.class.short_class_name
    rp.inline("") do
      rp.write(name, color: :blue)
      rp.write("[")
    end
    rp.multiline(after: "]", separator: ",") do
      self.to_h.each do |name, value|
        rp.inline(": ") do
          rp.write(name, color: :bright_cyan)
          rp(value)
        end
      end
    end
  end
end

class Struct < Object
  def report_print
    name = self.class.short_class_name
    rp.inline(" ") do
      rp.inline("") do
        rp.write(name, color: :bright_yellow)
        rp.write("(")
      end
      rp.write_object_id(self)
    end
    rp.multiline(after: ")", separator: ",") do
      self.to_h.each do |name, value|
        rp.inline(": ") do
          rp.write(name, color: :bright_cyan)
          rp(value)
        end
      end
    end
  end
end

module Kernel
  def rp(object = ReportPrint::Printer, output: $>, color: :auto)
    if object == ReportPrint::Printer
      Fiber[:report_printer]
    elsif Fiber[:report_printer].is_a?(ReportPrint::Printer)
      Fiber[:report_printer].rp(object)
    else
      fiber = Fiber.new do
        Fiber[:report_printer] = ReportPrint::Printer.new(output, color:)
        Fiber[:report_printer].rp(object)
        output.write("\n")
      end
      fiber.resume
    end
  end
end
