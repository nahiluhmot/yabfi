module Brainfuck
  # This module consumes tokens produced by the Parser and produces an
  # unoptimized syntax tree.
  class Lexer < Consumer
    # This Hash maps tokens to method names to optimize the performance of the
    # lexer.
    DISPATCH_TABLE = {
      loop: :while_loop,
      succ: :change_value,
      pred: :change_value,
      next: :change_pointer,
      prev: :change_pointer,
      get: :get,
      put: :put
    }

    # Run the lexer on the given tokens.
    #
    # @param tokens [Array<Symbol>] the input tokens.
    # @raise [Consumer::Error] when the lexing fails.
    # @return [Array<Object>] the lexed syntax tree.
    def self.run!(tokens)
      new(tokens).send(:run!)
    end

    private

    def run!
      forest = commands
      return forest if end_of_input?
      fail Consumer::Unsatisfied, "Unexpected token #{peek}"
    end

    def commands
      many { command }
    end

    def command
      method = DISPATCH_TABLE[peek]
      fail Consumer::Unsatisfied, "Unexpected token #{peek}" unless method
      send(method)
    end

    def while_loop
      eq(:loop)
      inner = commands
      eq(:end)
      [:loop, inner]
    end

    def get
      count = many_one { eq(:get) }.count
      [:get, count]
    end

    def put
      count = many_one { eq(:put) }.count
      [:put, count]
    end

    def change_value
      toks = many_one { one_of(:succ, :pred) }
      total = toks.reduce(0) { |a, e| e == :succ ? a.succ : a.pred }
      [:change_value, total]
    end

    def change_pointer
      toks = many_one { one_of(:next, :prev) }
      total = toks.reduce(0) { |a, e| e == :next ? a.succ : a.pred }
      [:change_pointer, total]
    end
  end
end
