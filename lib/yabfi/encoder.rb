module YABFI
  # This module encodes the human-readable instruction names to integers.
  module Encoder
    # Mapping of human readable instruction names to their encoded integers.
    INSTRUCTIONS = {
      change_value: 0,
      change_pointer: 1,
      get: 2,
      put: 3,
      branch_if_zero: 4,
      branch_not_zero: 5
    }

    module_function

    # Encode a list of instructions into
    def encode(ary)
      ary.map { |(code, argument)| [INSTRUCTIONS[code], argument] }
    end
  end
end
