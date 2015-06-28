# Brainfuck is the top level module for the gem.
module Brainfuck
  # This is the base error for the gem from which the rest of the errors
  # subclass.
  BaseError = Class.new(StandardError)
end

require 'brainfuck/version'
require 'brainfuck/consumer'
require 'brainfuck/parser'
require 'brainfuck/lexer'
require 'brainfuck/unroll'
require 'brainfuck/virtual_machine'
