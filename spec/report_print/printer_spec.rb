using Rainbow

class Example1
  def initialize
    @test = 1
  end
end

RSpec.describe ReportPrint::Printer do
  subject(:printer) { described_class.new(output, color: false) }

  let(:output) { StringIO.new }

  def printer_block
    Fiber.new do
      Fiber[:report_printer] = printer
      yield
      output.write("\n")
    end.resume
  end

  it "writes strings" do
    printer_block do
      rp.write("test string")
    end
    expect(output.string).to eq("test string\n")
  end

  it "joins inline strings" do
    printer_block do
      rp.inline("-") do
        rp.write("one")
        rp.inline("+") do
          rp.write("two")
          rp.write("three")
        end
      end
    end
    expect(output.string).to eq("one-two+three\n")
  end

  it "joins multiline strings" do
    printer_block do
      rp.write("one")
      rp.write("two")
      rp.multiline(separator: ",") do
        rp.write("three")
        rp.write("four")
        rp.multiline do
          rp.write("five")
          rp.write("six")
        end
      end
    end

    expect(output.string).to eq(<<~EXAMPLE.lstrip)
      one
      two
        three,
        four
          five,
          six
      EXAMPLE
  end

  it "interleaves join types" do
    printer_block do
      rp.inline("+") do
        rp.write("one")
        rp.write("[")
        rp.multiline(separator: ",", after: "]") do
          rp.write("two")
          rp.inline("-") do
            rp.write("three")
            rp.write("four")
          end
          rp.write("five")
        end
        rp.write("six")
      end
    end

    expect(output.string).to eq(<<~EXAMPLE.lstrip)
      one+[
        two,
        three-four,
        five
      ]+six
      EXAMPLE
  end

  it "closes empty blocks" do
    printer_block do
      rp.inline("+") do
        rp.write("one")
        rp.write("[")
        rp.multiline(separator: ",", after: "]") { }
        rp.write("two")
      end
    end
    # TODO: there should be a setting controlling whether it produces that extra newline
    expect(output.string).to eq("one+[\n]+two\n")
  end

  it "allows skipping closing empty blocks" do
    printer_block do
      rp.inline("+") do
        rp.write("one")
        rp.write("[")
        rp.multiline(separator: ",", after: "]", after_empty: false) { }
        rp.write("two")
      end
    end
    expect(output.string).to eq("one+[+two\n")
  end

  it "hides repeated items" do
    object = Example1.new

    printer_block do
      2.times do
        rp.unless_seen(object) do
          rp.write_header(object)
          rp.multiline(after: "end") do
            rp.write_instance_variables(object)
          end
        end
      end
    end

    id = sprintf("%#x", object.__id__)

    expect(output.string).to eq(<<~EXAMPLE.lstrip)
      Example1 #{id}
        @test = 1
      end
      Example1 #{id}
    EXAMPLE
  end

  context "with color" do
    subject(:printer) { described_class.new(output, color: true) }

    let(:rainbow) { Rainbow::Wrapper.new(true) }

    it "writes using the color argument" do
      printer_block do
        rp.write("test string", color: :red)
      end
      expect(output.string).to eq("test string".red + "\n")
    end

    it "accepts bright prefixed colors" do
      printer_block do
        rp.write("test string", color: :bright_red)
      end
      expect(output.string).to eq("test string".red.bright + "\n")
    end

    it "provides access to a rainbow wrapper" do
      printer_block do
        rp.write(
          rp.color("test string", :bright_blue),
          rp.color("more", :aqua).underline
        )
      end
      expect(output.string).to eq(
        "test string".blue.bright +
        "more".color(:aqua).underline +
        "\n"
      )
    end

    it "writes headers" do
      object = Example1.new
      printer_block do
        rp.write_header(object)
      end

      expect(output.string).to eq(
        "Example1".yellow.bright +
        " " +
        sprintf("%#x", object.__id__).black.bright +
        "\n"
      )
    end

    it "writes object ids" do
      object = Example1.new
      printer_block do
        rp.write_object_id(object)
      end

      expect(output.string).to eq(
        sprintf("%#x", object.__id__).black.bright + "\n"
      )
    end

    it "writes instance variables" do
      object = Example1.new
      printer_block do
        rp.write_instance_variables(object)
      end

      expect(output.string).to eq(
        "@test".cyan.bright + " = " + "1".magenta.bright + "\n"
      )
    end
  end
end
