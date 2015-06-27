module Brainfuck
  # This module is used to transforms unrolls loops into multiple
  # branch_if_zero and branch_not_zero instructions.
  module Unroll
    module_function

    # Unroll an entire syntax forest.
    #
    # @param forest [Array<Object>] the forest to unroll.
    # @return [Array<Object>] the unrolled commands.
    def unroll(forest)
      forest.each_with_object([]) do |(command, arg), ary|
        if command == :loop
          ary.push(*unroll_loop(arg))
        else
          ary.push([command, arg])
        end
      end
    end

    # Unroll a single loop of commands.
    #
    # @param commands [Array<Object>] the loop to unroll.
    # @return [Array<Object>] the unrolled commands.
    def unroll_loop(commands)
      unroll(commands).tap do |unrolled|
        offset = unrolled.length
        unrolled.unshift([:branch_if_zero, offset + 2])
        unrolled.push([:branch_not_zero, -1 * offset])
      end
    end
  end
end
