using ReportPrint::Refinements

class ::Module < ::Object
  def report_print(rp)
    rp.write(short_class_name, color: :bright_yellow)
  end
end

class ::Object < ::BasicObject
  report_print_options(detect_cycles: true)

  def report_print(rp)
    rp.write_header(self)
    rp.multiline(after: rp.color("end", :bright_blue), after_empty: false) do
      rp.write_instance_variables(self)
    end
  end

  def report_print_cycle(rp)
    rp.write_header(self)
  end
end

class ::Symbol < ::Object
  report_print_options(color: :bright_blue, detect_cycles: false)
  report_print_inspect!
end

class ::TrueClass < ::Object
  report_print_options(color: :bright_blue, detect_cycles: false)
  report_print_inspect!
end

class ::FalseClass < ::Object
  report_print_options(color: :bright_blue, detect_cycles: false)
  report_print_inspect!
end

class ::Numeric < ::Object
  report_print_options(color: :bright_magenta, detect_cycles: false)
  report_print_inspect!
end

class ::String < ::Object
  report_print_options(color: :bright_green, detect_cycles: false)
  report_print_inspect!
end

class ::NilClass < ::Object
  report_print_options(color: :bright_blue, detect_cycles: false)
  report_print_inspect!
end

class ::Regexp < ::Object
  report_print_options(color: :yellow, detect_cycles: false)
  report_print_inspect!
end

class ::Range < ::Object
  report_print_options(detect_cycles: false)

  def report_print(rp)
    first = self.first rescue nil
    last = self.last rescue nil

    rp.inline("") do
      rp.write("(")
      unless first.nil?
        rp.rp(first)
      end
      rp.write("..")
      if exclude_end?
        rp.write(".")
      end
      unless last.nil?
        rp.rp(last)
      end
      rp.write(")")
    end
  end
end

class ::Enumerator::ArithmeticSequence ::Enumerator
  report_print_options(detect_cycles: false)

  def report_print(rp)
    rp.inline("") do
      rp.write("(")
      unless self.begin.nil?
        rp.rp(self.begin)
      end
      rp.write("..")
      if exclude_end?
        rp.write(".")
      end
      unless self.end.nil?
        rp.rp(self.end)
      end
      rp.write(")")
      unless step == 1
        rp.write(".step(")
        rp.rp(step)
        rp.write(")")
      end
    end
  end
end

class ::Array < ::Object
  report_print_options(detect_cycles: false)

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
  report_print_options(detect_cycles: false)

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
  report_print_options(detect_cycles: false)

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
  report_print_options(detect_cycles: false)

  def report_print(rp)
    name = self.class.short_class_name
    rp.inline("") do
      rp.write(name, color: :blue)
      rp.write("[")
    end
    rp.multiline(after: "]", separator: ",") do
      self.to_h.each do |name, value|
        rp.inline(" ") do
          rp.inline("") do
            rp.write(name, color: :bright_cyan)
            rp.write(":")
          end
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
