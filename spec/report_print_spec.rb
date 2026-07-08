RSpec.describe ReportPrint do
  subject(:printer) { ReportPrint::Printer.new(output) }

  let(:output) { StringIO.new }

  it "has a version number" do
    expect(ReportPrint::VERSION).not_to be_nil
  end

  it "does something useful" do
    printer.rp(printer)
    expect(output.string).to eq("Printer")
  end
end
