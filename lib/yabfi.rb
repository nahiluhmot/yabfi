# YABFI (Yet Another BrainFuck Interpreter) is the top level module for the gem.
module YABFI
  # This is the base error for the gem from which the rest of the errors
  # subclass.
  BaseError = Class.new(StandardError)

  module_function

  # Evaluate an IO of commands
  #
  # @param commands [String, IO] the commands to execute.
  # @param input [IO] the input from which the commands read.
  # @param output [IO] the output to which the commands write.
  # @param eof [Integer] the value to set when EOF is reached.
  # @raise [BaseError] when there is a compiling or execution error.
  def eval!(commands, input = $stdin, output = $stdout, eof = 0)
    io = commands.is_a?(String) ? StringIO.new(commands) : commands
    tokens = Parser.parse(io)
    lexed = Lexer.run!(tokens.to_a)
    commands = Unroll.unroll(lexed)
    vm = VirtualMachine.new(input, output, eof)
    vm.load!(commands)
    vm.execute!
  end
end

require 'yabfi/version'
require 'yabfi/consumer'
require 'yabfi/parser'
require 'yabfi/lexer'
require 'yabfi/unroll'
require 'yabfi/virtual_machine'
