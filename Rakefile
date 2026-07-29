require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rdoc/task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "_site"
end

task default: %i[spec rubocop]
