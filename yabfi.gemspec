# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yabfi/version'

Gem::Specification.new do |spec|
  spec.name                  = 'yabfi'
  spec.version               = YABFI::VERSION
  spec.authors               = ['Tom Hulihan']
  spec.email                 = ['hulihan.tom159@gmail.com']
  spec.summary               = 'Yet Another BrainFuck Interpreter'
  spec.description           = spec.summary
  spec.homepage              = 'https://github.com/nahiluhmot/yabfi'
  spec.license               = 'MIT'
  spec.files                 = [
    `git ls-files -z`.split("\x0"),
    'lib/yabfi/vm.bundle'
  ].flatten
  spec.require_paths         = ['lib']
  spec.executables           = ['yabfi']
  spec.required_ruby_version = '>= 2.0.0'
  spec.extensions            = ['ext/yabfi/extconf.rb']
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rake-compiler', '~> 0.9.5'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'simplecov'
end
