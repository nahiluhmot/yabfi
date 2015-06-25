require 'spec_helper'

describe Brainfuck::Consumer do
  subject { described_class.new(input) }
  let(:input) { [] }

  describe '#end_of_input?' do
    let(:input) { [1, 2, 3] }

    context 'when all of the input has been consumed' do
      before { subject.seek(input.length) }

      it 'returns true' do
        expect(subject).to be_end_of_input
      end
    end

    context 'when some of the input has not been consumed' do
      it 'returns false' do
        input.length.times do |int|
          subject.seek(int)
          expect(subject).to_not be_end_of_input
        end
      end
    end
  end

  describe '#peek' do
    let(:input) { %w(a b c) }

    context 'when all of the input has been consumed' do
      before { subject.seek(input.length) }

      it 'fails with EndOfInput' do
        expect { subject.peek }.to raise_error(described_class::EndOfInput)
      end
    end

    context 'when some of the input has not been consumed' do
      it 'returns the next character in the Array' do
        input.each_with_index do |sym, int|
          subject.seek(int)
          expect(subject.peek).to eq(sym)
        end
      end

      it 'does not advance the parse' do
        expect { subject.peek }.to_not change { subject.consume_index }
      end
    end
  end

  describe '#advance' do
    let(:input) { %w(a b c d e f) }

    context 'when all of the input has been consumed' do
      before { subject.seek(input.length) }

      it 'fails with EndOfInput' do
        expect { subject.advance }.to raise_error(described_class::EndOfInput)
      end
    end

    context 'when some of the input has not been consumed' do
      it 'returns the next character in the Array and advances the parse' do
        input.each { |str| expect(subject.advance).to eq(str) }
        expect { subject.advance }.to raise_error(described_class::EndOfInput)
      end
    end
  end

  describe '#satisfy' do
    let(:input) { (0..9).to_a }

    context 'when all of the input has been consumed' do
      before { subject.seek(input.length) }

      it 'fails with EndOfInput' do
        expect { subject.satisfy(&:odd?) }
          .to raise_error(described_class::EndOfInput)
      end
    end

    context 'when some of the input has not been consumed' do
      context 'but the predicate returns a falsey value' do
        it 'fails with a Unsatisfied' do
          expect { subject.satisfy(&:odd?) }
            .to raise_error(Brainfuck::Consumer::Unsatisfied)
        end
      end

      context 'and the predicate returns a truthy value' do
        it 'returns the matched token and advances the parse' do
          input.each do |num|
            predicate = num.even? ? :even? : :odd?
            expect(subject.satisfy(&predicate)).to eq(num)
          end
        end
      end
    end
  end

  describe '#eq' do
    let(:input) { %w(cat dog chicken) }

    context 'when all of the input has been consumed' do
      before { subject.seek(input.length) }

      it 'fails with EndOfInput' do
        expect { subject.eq('cat') }.to raise_error(described_class::EndOfInput)
      end
    end

    context 'when some of the input has not been consumed' do
      context 'but the expected token does not match the actual token' do
        it 'fails with a Unsatisfied' do
          expect { subject.eq('dog') }
            .to raise_error(Brainfuck::Consumer::Unsatisfied)
        end
      end

      context 'and the expeted token matches the actual token' do
        it 'returns the matched token and advances the parse' do
          input.each { |str| expect(subject.eq(str)).to eq(str) }
        end
      end
    end
  end

  describe '#one_of' do
    let(:input) { %i(foo bar baz) }

    context 'when all of the input has been consumed' do
      before { subject.seek(input.length) }

      it 'fails with EndOfInput' do
        expect { subject.one_of(*input) }
          .to raise_error(described_class::EndOfInput)
      end
    end

    context 'when some of the input has not been consumed' do
      context 'but the expeted tokens do not match the actual token' do
        it 'fails with a Unsatisfied' do
          expect { subject.one_of(:hey, :hi, :howdy) }
            .to raise_error(Brainfuck::Consumer::Unsatisfied)
        end
      end

      context 'and the expeted tokens match the actual token' do
        it 'returns the matched token and advances the parse' do
          expect(subject.one_of(:foo, :bar)).to eq(:foo)
          expect(subject.one_of(:bar, :baz)).to eq(:bar)
          expect(subject.one_of(:baz, :foo)).to eq(:baz)
        end
      end
    end
  end

  describe '#attempt' do
    let(:input) { [1, :mixed, 'array', nil] }

    context 'when the parse fails with in the given block' do
      it 'returns nil' do
        expect(subject.attempt { token(:mixed) }).to be(nil)
      end

      it 'resets the counter' do
        expect { subject.attempt { [1, 2].each { |n| subject.eq(n) } } }
          .to_not change { subject.consume_index }
      end
    end

    context 'when the parse does not fail with in the given block' do
      it 'returns the result' do
        expect(subject.attempt { subject.satisfy(&:odd?) }).to eq(1)
      end

      it 'advances the parse' do
        expect { subject.attempt { subject.eq(1) } }
          .to change { subject.consume_index }
          .from(0)
          .to(1)
      end
    end
  end

  describe '#many' do
    let(:input) { [2, 4, 6, 8, 9] }

    it 'calls the given block until it fails or returns nil' do
      expect(subject.many { subject.satisfy(&:even?) }).to eq([2, 4, 6, 8])
      expect(subject.eq(9)).to eq(9)
      expect(subject).to be_end_of_input
    end
  end

  describe '#many_one' do
    let(:input) { [1, 3, 5, 2, 4, 6] }

    context 'when 0 results can be matched' do
      it 'fails with Unsatisfied' do
        expect { subject.many_one { subject.eq(2) } }
          .to raise_error(described_class::Unsatisfied)
      end
    end

    context 'when 1 result can be matched' do
      it 'advances the parse and returns the result' do
        expect(subject.many_one { subject.eq(1) }).to eq([1])
        expect(subject.many_one { subject.eq(3) }).to eq([3])
      end
    end

    context 'when many results can be matched' do
      it 'advances the parse and returns the results' do
        expect(subject.many_one { subject.satisfy(&:odd?) }).to eq([1, 3, 5])
        expect(subject.many_one { subject.satisfy(&:even?) }).to eq([2, 4, 6])
        expect(subject).to be_end_of_input
      end
    end
  end
end
