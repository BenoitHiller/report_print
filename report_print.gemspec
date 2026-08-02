require_relative "lib/report_print/version"

Gem::Specification.new do |spec|
  spec.name = "report_print"
  spec.version = ReportPrint::VERSION
  spec.authors = ["Benoit Hiller"]
  spec.email = ["benoit.hiller@gmail.com"]
  spec.licenses = ["MIT-0"]

  spec.summary = "A hybrid between PrettyPrint and AwesomePrint/AmazingPrint"
  spec.description = File.read(File.join(__dir__, "gem_description.rdoc"))
  spec.homepage = "https://benoithiller.github.io/report_print/"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/BenoitHiller/report_print"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Rakefile Gemfile . spec/])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rainbow", "~> 3.1"
end
