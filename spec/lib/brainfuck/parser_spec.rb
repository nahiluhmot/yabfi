require 'spec_helper'

describe Brainfuck::Parser do
  describe '.parse' do
    let(:io) { StringIO.new('+-<>,.[] some comment') }
    let(:enum) { subject.parse(io) }
    let(:expected) { %i(succ pred prev next get put loop end) }

    it 'returns an Enumator that yields each command from the given IO' do
      expect(enum.to_a).to eq(expected)
    end
  end
end
