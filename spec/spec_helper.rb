require "report_print"
require "rainbow/refinement"

using Rainbow

# rubocop:disable RSpec/ContextWording
RSpec.shared_context "rp", shared_context: :metadata do
  let(:output) { StringIO.new }

  let(:rp) do |example|
    ReportPrint::Printer.new(output, color: example.metadata[:color])
  end

  def oid
    "0x1".black.bright
  end

  before(:example, object_id: :stub) do
    # Make it much easier to write out the expected text not requiring us to
    # compute object ids everywhere.
    allow(rp).to receive(:write_object_id) do
      rp.write(oid)
    end
  end
end
# rubocop:enable RSpec/ContextWording

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    @rainbow_default = Rainbow.enabled
    Rainbow.enabled = !!self.class.metadata[:color]
  end

  config.after do
    Rainbow.enabled = @rainbow_default
  end

  config.include_context "rp"
end
