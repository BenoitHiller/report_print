using Rainbow

class Example1
  def initialize
    @test = 1
  end
end

DataExample = Data.define(:one)

RSpec.describe ReportPrint::Printer do
  it "writes strings" do
    rp.write("test string")
    expect(output.string).to eq("test string")
  end

  it "joins inline strings" do
    rp.inline("-") do
      rp.write("one")
      rp.inline("+") do
        rp.write("two")
        rp.write("three")
      end
    end
    expect(output.string).to eq("one-two+three")
  end

  it "joins multiline strings" do
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

    expect(output.string).to eq(<<~EXAMPLE.strip)
      one
      two
        three,
        four
          five
          six
      EXAMPLE
  end

  it "interleaves join types" do
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

    expect(output.string).to eq(<<~EXAMPLE.strip)
      one+[
        two,
        three-four,
        five
      ]+six
      EXAMPLE
  end

  it "closes empty blocks" do
    rp.inline("+") do
      rp.write("one")
      rp.write("[")
      rp.multiline(separator: ",", after: "]") { }
      rp.write("two")
    end

    expect(output.string).to eq("one+[]+two")
  end

  it "allows skipping closing empty blocks" do
    rp.inline("+") do
      rp.write("one")
      rp.write("[")
      rp.multiline(separator: ",", after: "]", after_empty: false) { }
      rp.write("two")
    end
    expect(output.string).to eq("one+[+two")
  end

  it "hides repeated items" do
    object = Example1.new

    2.times do
      rp.rp(object)
    end

    id = sprintf("%#x", object.__id__)

    expect(output.string).to eq(<<~EXAMPLE.strip)
      Example1 #{id}
        @test = 1
      end
      Example1 #{id}
    EXAMPLE
  end

  it "respects the detect_cycles option" do
    2.times do
      rp.rp(DataExample[1])
    end

    expect(output.string).to eq(<<~EXAMPLE.strip)
    DataExample[
      one: 1
    ]
    DataExample[
      one: 1
    ]
    EXAMPLE
  end

  context "with color", :color do
    it "writes using the color argument" do
      rp.write("test string", color: :red)
      expect(output.string).to eq("test string".red)
    end

    it "accepts bright prefixed colors" do
      rp.write("test string", color: :bright_red)
      expect(output.string).to eq("test string".red.bright)
    end

    it "provides access to a rainbow wrapper" do
      rp.write(
        rp.color("test string", :bright_blue),
        rp.color("more", :aqua).underline
      )
      expect(output.string).to eq(
        "test string".blue.bright +
        "more".color(:aqua).underline
      )
    end

    it "writes headers" do
      object = Example1.new
      rp.write_header(object)

      expect(output.string).to eq(
        "Example1".yellow.bright +
        " " +
        sprintf("%#x", object.__id__).black.bright
      )
    end

    it "writes object ids" do
      object = Example1.new
      rp.write_object_id(object)

      expect(output.string).to eq(
        sprintf("%#x", object.__id__).black.bright
      )
    end

    it "writes instance variables" do
      object = Example1.new
      rp.write_instance_variables(object)

      expect(output.string).to eq(
        "@test".cyan.bright + " = " + "1".magenta.bright
      )
    end
  end
end
