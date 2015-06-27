require 'spec_helper'

describe Brainfuck::Unroll do
  describe '.unroll' do
    let(:tokens) do
      %i(
        succ
        succ
        next
        loop
        loop
        prev
        end
        loop
        get
        end
        next
        end
        put
        pred
      )
    end
    let(:input) { Brainfuck::Lexer.run!(tokens) }
    let(:expected) do
      [
        [:change_value, 2],
        [:change_pointer, 1],
        [:branch_if_zero, 9],
        [:branch_if_zero, 3],
        [:change_pointer, -1],
        [:branch_not_zero, -1],
        [:branch_if_zero, 3],
        [:get, 1],
        [:branch_not_zero, -1],
        [:change_pointer, 1],
        [:branch_not_zero, -7],
        [:put, 1],
        [:change_value, -1]
      ]
    end

    it 'unrolls the syntax forest' do
      expect(subject.unroll(input)).to eq(expected)
    end
  end
end
