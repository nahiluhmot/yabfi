# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brainfuck/version'

Gem::Specification.new do |spec|
  spec.name          = 'brainfuck'
  spec.version       = Brainfuck::VERSION
  spec.authors       = ['Tom Hulihan']
  spec.email         = ['hulihan.tom159@gmail.com']
  spec.summary       = 'A brainfuck interpreter written in Ruby'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/nahiluhmot/brainfuck'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']
  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'pry-rescue'
end
