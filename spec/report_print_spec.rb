using Rainbow

TestStruct = Struct.new(:a, :b) do
  const_set(:Name, "TestStruct".yellow.bright)
end
TestData = Data.define(:c, :d) do
  const_set(:Name, "TestData".blue)
end

OID = "0x1".black.bright

class TestClass
  Name = "TestClass".yellow.bright
  def initialize
    @one = 1
    @two = ["a", :'2']
    @three = TestStruct.new(3, TestData[true, "six"])
  end
end

class TestClass2 < TestClass
  Name = "TestClass2".yellow.bright
  def initialize
    super
    @four = TestClass.new
  end
end

RSpec.describe ReportPrint do
  let(:printer) do
    ReportPrint::Printer.new(output)
  end
  let(:output) { StringIO.new }

  before(:example, object_id: :stub) do
    # Make it much easier to write out the expected text not requiring us to
    # compute object ids everywhere.
    allow(printer).to receive(:write_object_id) do
      printer.write("0x1", color: :bright_black)
    end
  end

  def print_object(object)
    Fiber.new do
      Fiber[:report_printer] = printer
      printer.rp(object)
      output.write("\n")
    end.resume
  end

  it "has a version number" do
    expect(ReportPrint::VERSION).not_to be_nil
  end

  it "inspects strings" do
    print_object("test string")
    expect(output.string).to eq(%Q("test string"\n))
  end

  it "inspects arrays" do
    print_object([1, :a, "a"])
    expect(output.string).to eq(<<~EXAMPLE.lstrip)
    [
      1,
      :a,
      "a"
    ]
    EXAMPLE
  end

  it "inspects hashes" do
    print_object({
      a: 1,
      b: { c: "c" },
      "d" => 4,
      { e: 5, f: 6 } => 7
    })
    expect(output.string).to eq(<<~EXAMPLE.lstrip)
    {
      a: 1,
      b: {
        c: "c"
      },
      "d" => 4,
      {
        e: 5,
        f: 6
      } => 7
    }
    EXAMPLE
  end

  it "inspects sets" do
    print_object(Set[1, "a", [2, 3]])
    # Note that sets aren't necessarily ordered, but these arguments produce a
    # consistent result currently.
    expect(output.string).to eq(<<~EXAMPLE.lstrip)
    Set[
      1,
      "a",
      [
        2,
        3
      ]
    ]
    EXAMPLE
  end

  it "inspects data objects" do
    print_object(TestData["c", 4])

    expect(output.string).to eq(<<~EXAMPLE.lstrip)
    TestData[
      c: "c",
      d: 4
    ]
    EXAMPLE
  end

  it "inspects structs", object_id: :stub do
    struct = TestStruct.new("a", 2)
    print_object(struct)

    expect(output.string).to eq(<<~EXAMPLE.lstrip)
    TestStruct( 0x1
      a: "a",
      b: 2
    )
    EXAMPLE
  end

  it "inspects objects", object_id: :stub do
    print_object(TestClass.new)
    expect(output.string).to eq(<<~EXAMPLE.lstrip)
    TestClass 0x1
      @one = 1
      @two = [
        "a",
        :"2"
      ]
      @three = TestStruct( 0x1
        a: 3,
        b: TestData[
          c: true,
          d: "six"
        ]
      )
    end
    EXAMPLE
  end

  context "with color" do
    subject(:printer) { ReportPrint::Printer.new(output, color: true) }

    let(:rainbow) { Rainbow::Wrapper.new(true) }

    it "inspects strings" do
      print_object("test string")
      expect(output.string).to eq(rainbow.wrap('"test string"').color(:green).bright + "\n")
    end

    it "inspects objects", object_id: :stub do
      print_object(TestClass2.new)
      expect(output.string).to eq(<<~EXAMPLE.lstrip)
      #{TestClass2::Name} #{OID}
        #{"@one".cyan.bright} = #{"1".magenta.bright}
        #{"@two".cyan.bright} = [
          #{'"a"'.green.bright},
          #{':"2"'.cyan.bright}
        ]
        #{"@three".cyan.bright} = #{TestStruct::Name}( #{OID}
          #{"a".cyan.bright}: #{"3".magenta.bright},
          #{"b".cyan.bright}: #{TestData::Name}[
            #{"c".cyan.bright}: #{"true".blue.bright},
            #{"d".cyan.bright}: #{'"six"'.green.bright}
          ]
        )
        #{"@four".cyan.bright} = #{TestClass::Name} #{OID}
          #{"@one".cyan.bright} = #{"1".magenta.bright}
          #{"@two".cyan.bright} = [
            #{'"a"'.green.bright},
            #{':"2"'.cyan.bright}
          ]
          #{"@three".cyan.bright} = #{TestStruct::Name}( #{OID}
            #{"a".cyan.bright}: #{"3".magenta.bright},
            #{"b".cyan.bright}: #{TestData::Name}[
              #{"c".cyan.bright}: #{"true".blue.bright},
              #{"d".cyan.bright}: #{'"six"'.green.bright}
            ]
          )
        #{"end".blue.bright}
      #{"end".blue.bright}
      EXAMPLE
    end
  end
end
