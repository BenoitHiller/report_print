using ReportPrint::Refinements

class ::Object < ::BasicObject
  def report_print(rp)
    rp.unless_seen(self) do
      rp.write_header(self)
      rp.multiline(after: rp.color("end", :bright_blue), after_empty: false) do
        rp.write_instance_variables(self)
      end
    end
  end
end

class ::Module < ::Object
  def report_print(rp)
    rp.write(name.short_class_name)
  end
end

class ::Symbol < ::Object
  report_print_inspect!(color: :bright_blue)
end

class ::TrueClass < ::Object
  report_print_inspect!(color: :bright_blue)
end

class ::FalseClass < ::Object
  report_print_inspect!(color: :bright_blue)
end

class ::Numeric < ::Object
  report_print_inspect!(color: :bright_magenta)
end

class ::String < ::Object
  report_print_inspect!(color: :bright_green)
end

class ::NilClass < ::Object
  report_print_inspect!(color: :bright_blue)
end

class ::Array < ::Object
  def report_print(rp)
    rp.write("[")
    rp.multiline(after: "]", separator: ",") do
      to_a.each do |item|
        rp.rp(item)
      end
    end
  end
end

class ::Hash < ::Object
  def report_print(rp)
    rp.write("{")
    rp.multiline(after: "}", separator: ",") do
      each do |key, value|
        rp.inline(" ") do
          case key
          in Symbol
            rp.write(key, ":", color: :bright_cyan)
          else
            rp.rp(key)
            rp.write("=>")
          end

          rp.rp(value)
        end
      end
    end
  end
end

class ::Set < ::Object
  def report_print(rp)
    rp.inline("") do
      rp.write("Set", color: :yellow)
      rp.write("[")
    end
    rp.multiline(after: "]", separator: ",") do
      to_a.each do |item|
        rp.rp(item)
      end
    end
  end
end

class ::Data < ::Object
  def report_print(rp)
    name = self.class.short_class_name
    rp.inline("") do
      rp.write(name, color: :blue)
      rp.write("[")
    end
    rp.multiline(after: "]", separator: ",") do
      self.to_h.each do |name, value|
        rp.inline(": ") do
          rp.write(name, color: :bright_cyan)
          rp.rp(value)
        end
      end
    end
  end
end

class ::Struct < ::Object
  def report_print(rp)
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
          rp.rp(value)
        end
      end
    end
  end
end
