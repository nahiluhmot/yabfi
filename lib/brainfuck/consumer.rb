module Brainfuck
  # This class provides generic methods to declaratively consume an Array of
  # input.
  class Consumer
    # Base error for all Consumer errors.
    Error = Class.new(StandardError)

    # Raised when the expected input does not match the given input.
    Unsatisfied = Class.new(Error)

    # Raised when the end of input is reached.
    EndOfInput = Class.new(Error)

    # @attr_reader [Array<Object>] tokens to consume.
    attr_reader :tokens

    # Create a new Consumer.
    #
    # @param tokens [Array<Object>] consumer input.
    def initialize(tokens)
      @tokens = tokens
    end

    # Lazily evaluated _conumer_idx instnace variable.
    #
    # @return [Integer] of the current index of the input consumption.
    def consume_index
      @consume_index ||= 0
    end

    # Seek to the given posision.
    #
    # @param n [Integer] the integer to seek to.
    def seek(n)
      @consume_index = n
    end

    # Test if the parse has completed.
    #
    # @return [true, false] whether or not the input has been fully consumed.
    def end_of_input?
      consume_index >= tokens.length
    end

    # Look at the next character of input without advancing the consumption.
    #
    # @return [Object] the next token in the parse.
    # @raise [EndOfInput] if the parse has completed.
    def peek
      fail EndOfInput, '#peek: end of input' if end_of_input?
      tokens[consume_index]
    end

    # Look at the next character of input and advance the parse by one element.
    #
    # @return [Object] the next token in the parse.
    # @raise [EndOfInput] if the parse has completed.
    def advance
      peek.tap { seek(consume_index.succ) }
    end

    # Given an optional error message and predicate, test if the next token in
    # the parse satisfies the predicate.
    #
    # @param message [String] error message to throw when the condition is not
    #                         satisfied.
    # @yieldparam token [Object] the token to test.
    # @return [Object] the satisfied token.
    # @raise [EndOfInput] if the parse has completed.
    # @raise [Unsatisfied] if the condition is not met.
    def satisfy(message = nil)
      message ||= '#satisfy:'
      tok = peek
      fail Unsatisfied, "#{message} '#{tok}'" unless yield(tok)
      seek(consume_index.succ)
      tok
    end

    # Declare that the next token in the stream should be the given token.
    #
    # @param expected [Object] next expected object in the parse.
    # @return [Object] the satisfied token.
    # @raise [EndOfInput] if the parse has completed.
    # @raise [Unsatisfied] if the token does not equal the argument.
    def eq(expected)
      satisfy("Expected #{expected}, got:") { |tok| tok == expected }
    end

    # Declare that the next token in the stream should match the given token.
    #
    # @param toks [Array<Object>] list of objects that could match.
    # @return [Object] the satisfied token.
    # @raise [EndOfInput] if the parse has completed.
    # @raise [Unsatisfied] if the token cannot me matched.
    def one_of(*toks)
      satisfy("Expected one of #{toks}, got:") { |tok| toks.include?(tok) }
    end

    # Try a block of code, resetting the parse state on failure.
    #
    # @return [Object, nil] the result of the block, or nil if the block fails.
    def attempt
      idx = consume_index
      yield
    rescue
      seek(idx)
      nil
    end

    # Consume 0 or more occurrences of the given block.
    #
    # @return [Object, nil] the result of the block, or nil if the block fails.
    def many
      idx = consume_index
      results = []
      loop do
        idx = consume_index
        results << yield
      end
    rescue
      seek(idx)
      results
    end

    # Consume 1 or more occurrences of the given block.
    #
    # @return [Object, nil] the result of the block, or nil if the block fails.
    def many_one(&block)
      many(&block).tap do |results|
        fail Unsatisfied, '#many_one: got no results' if results.empty?
      end
    end
  end
end
