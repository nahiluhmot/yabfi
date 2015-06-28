require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'pry'
require 'yard'

desc 'Run the specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run the code quality metrics'
RuboCop::RakeTask.new(:quality)

desc 'Generate gem documentation'
YARD::Rake::YardocTask.new(:doc)

desc 'Start a pry shell in the context of the YABFI module'
task :shell do
  Pry.start(YABFI)
end

task default: [:spec, :quality, :doc]
