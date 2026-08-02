# Inherit from BasicObject simply to avoid including the default options such
# as detect_cycles: true
class A < BasicObject
  report_print_options(a: 1, b: 2, c: 3)
end

class B < A
  report_print_options(a: nil, b: -2, d: 4)
end

RSpec.describe ReportPrint::ScopedOptions do
  subject(:options) { described_class.new(initial) }

  let(:initial) { {} }

  it "merges superclass options" do
    expect(options.options_for(B)).to eq({
      b: -2, c: 3, d: 4
    })
  end

  it "preserves superclass options" do
    expect(options.options_for(A)).to eq({
      a: 1, b: 2, c: 3
    })
  end

  context "with global options" do
    let(:initial) { { a: "a", d: "d", e: "e" } }

    it "merges global options" do
      expect(options.options_for(B)).to eq({
        a: "a", b: -2, c: 3, d: 4, e: "e"
      })
    end
  end
end
