RSpec.describe ReportPrint do
  subject(:printer) { ReportPrint::Printer.new(output) }

  let(:output) { StringIO.new }

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

  context "with color" do
    subject(:printer) { ReportPrint::Printer.new(output, color: true) }

    let(:rainbow) { Rainbow::Wrapper.new(true) }

    it "inspects strings" do
      print_object("test string")
      expect(output.string).to eq(rainbow.wrap('"test string"').color(:green).bright + "\n")
    end
  end
end
