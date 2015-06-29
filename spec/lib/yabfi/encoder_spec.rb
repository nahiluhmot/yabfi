require 'spec_helper'

describe YABFI::Encoder do
  describe '.encode' do
    let(:ary) do
      [
        [:put, 3],
        [:change_value, 4],
        [:branch_if_zero, 4],
        [:change_pointer, 1],
        [:get, 1],
        [:branch_not_zero, -2],
        [:branch_if_zero, 3],
        [:change_value, -1],
        [:branch_not_zero, -1],
        [:change_value, 65],
        [:put, 1]
      ]
    end
    let(:expected) do
      [
        [3, 3],
        [0, 4],
        [4, 4],
        [1, 1],
        [2, 1],
        [5, -2],
        [4, 3],
        [0, -1],
        [5, -1],
        [0, 65],
        [3, 1]
      ]
    end

    it 'encodes the instructions into integers' do
      expect(subject.encode(ary)).to eq(expected)
    end
  end
end
