using Rainbow

TestStruct = Struct.new(:a, :b) do
  def self.expected_name
    "TestStruct".yellow.bright
  end
end

TestData = Data.define(:c, :d) do
  def self.expected_name
    "TestData".blue
  end
end

class TestClass
  def self.expected_name
    "TestClass".yellow.bright
  end

  def initialize
    @one = 1
    @two = ["a", :'2']
    @three = TestStruct.new(3, TestData[true, "six"])
  end
end

class TestClass2 < TestClass
  def self.expected_name
    "TestClass2".yellow.bright
  end

  def initialize
    super
    @four = TestClass.new
  end
end

RSpec.describe ReportPrint do
  it "has a version number" do
    expect(ReportPrint::VERSION).not_to be_nil
  end

  it "inspects strings" do
    rp.rp("test string")
    expect(output.string).to eq('"test string"')
  end

  it "inspects arrays" do
    rp.rp([1, :a, "a"])
    expect(output.string).to eq(<<~EXAMPLE.strip)
    [
      1,
      :a,
      "a"
    ]
    EXAMPLE
  end

  it "inspects hashes" do
    rp.rp({
      a: 1,
      b: { c: "c" },
      "d" => 4,
      { e: 5, f: 6 } => 7
    })
    expect(output.string).to eq(<<~EXAMPLE.strip)
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
    rp.rp(Set[1, "a", [2, 3]])
    # Note that sets aren't necessarily ordered, but these arguments produce a
    # consistent result currently.
    expect(output.string).to eq(<<~EXAMPLE.strip)
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
    rp.rp(TestData["c", 4])

    expect(output.string).to eq(<<~EXAMPLE.strip)
    TestData[
      c: "c",
      d: 4
    ]
    EXAMPLE
  end

  it "inspects structs", object_id: :stub do
    rp.rp(TestStruct.new("a", 2))

    expect(output.string).to eq(<<~EXAMPLE.strip)
    TestStruct( 0x1
      a: "a",
      b: 2
    )
    EXAMPLE
  end

  it "inspects objects", object_id: :stub do
    rp.rp(TestClass.new)

    expect(output.string).to eq(<<~EXAMPLE.strip)
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

  context "with color", :color do
    it "inspects strings" do
      rp.rp("test string")

      expect(output.string).to eq('"test string"'.green.bright)
    end

    it "inspects objects", object_id: :stub do
      rp.rp(TestClass2.new)

      expect(output.string).to eq(<<~EXAMPLE.strip)
      #{TestClass2.expected_name} #{oid}
        #{"@one".cyan.bright} = #{"1".magenta.bright}
        #{"@two".cyan.bright} = [
          #{'"a"'.green.bright},
          #{':"2"'.blue.bright}
        ]
        #{"@three".cyan.bright} = #{TestStruct.expected_name}( #{oid}
          #{"a".cyan.bright}: #{"3".magenta.bright},
          #{"b".cyan.bright}: #{TestData.expected_name}[
            #{"c".cyan.bright}: #{"true".blue.bright},
            #{"d".cyan.bright}: #{'"six"'.green.bright}
          ]
        )
        #{"@four".cyan.bright} = #{TestClass.expected_name} #{oid}
          #{"@one".cyan.bright} = #{"1".magenta.bright}
          #{"@two".cyan.bright} = [
            #{'"a"'.green.bright},
            #{':"2"'.blue.bright}
          ]
          #{"@three".cyan.bright} = #{TestStruct.expected_name}( #{oid}
            #{"a".cyan.bright}: #{"3".magenta.bright},
            #{"b".cyan.bright}: #{TestData.expected_name}[
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
