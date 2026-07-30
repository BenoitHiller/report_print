require "bundler/gem_helper"
require "rspec/core/rake_task"
require "rdoc/task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "_site"
end

class GemHelperNoV < Bundler::GemHelper
  protected

  def version_tag
    # The existing code obnoxiously hardcodes a v here despite having a
    # variable for customizing the prefix
    "#{@tag_prefix}#{version}"
  end
end

GemHelperNoV.install_tasks

task default: %i[spec rubocop]
