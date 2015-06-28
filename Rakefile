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

desc 'Load the gem source code'
task :environment do
  lib = File.expand_path('lib', File.dirname(__FILE__))
  $LOAD_PATH << lib unless $LOAD_PATH.include?(lib)
  require 'yabfi'
end

desc 'Start a pry shell in the context of the YABFI module'
task shell: :environment do
  Pry.start(YABFI)
end

desc 'Clean the files generated by other tasks'
task :clean do
  %w(coverage doc pkg).each do |dir|
    path = File.expand_path(dir, File.dirname(__FILE__))
    next unless File.exist?(path)
    FileUtils.rm_rf(path)
  end
end

task default: [:clean, :spec, :quality, :doc]
