module YABFI
  # This module contains a set of functions that lazily parse an IO object and
  # yield a symbol for each non-comment character that is read in.
  module Parser
    # Maximum number of bytes to read in from the IO object at a time.
    DEFAULT_BUFFER_SIZE = 1_024

    # Maps characters to human-readable Symbol command names.
    COMMAND_MAPPINGS = {
      '+' => :succ,
      '-' => :pred,
      '>' => :next,
      '<' => :prev,
      ',' => :get,
      '.' => :put,
      '[' => :loop,
      ']' => :end
    }

    module_function

    # Lazily parse an IO object while it still has input.
    #
    # @param io [IO] the object from which the parser lazily reads.
    # @param buffer_size [Integer] maximum size to request from the IO at once.
    # @yield [command] Symbol that represents the parsed command.
    # @return [Enumator<Symbol>] of commands when no block is given.
    def parse(io, buffer_size = DEFAULT_BUFFER_SIZE)
      return enum_for(:parse, io, buffer_size) unless block_given?
      loop do
        buffer = read(io, buffer_size)
        break unless buffer
        buffer.each_char do |char|
          command = COMMAND_MAPPINGS[char]
          yield command if command
        end
      end
    end

    # Block waiting for the next set of commands.
    #
    # @param io [IO] the object from which the parser lazily reads.
    # @param size [Integer] the maximum number of bytes to read in.
    # @return [String, nil] the buffer of bytes read in, or nil on EOF.
    def read(io, size)
      io.read_nonblock(size)
    rescue IO::WaitReadable
      IO.select([io])
      retry
    rescue EOFError
      nil
    end
  end
end
