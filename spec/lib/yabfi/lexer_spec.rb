require 'spec_helper'

describe YABFI::Lexer do
  subject { described_class }

  describe '#run!' do
    context 'when all of the input cannot be consumed' do
      let(:input) do
        %i(
          loop
          end
          pred
          fail
        )
      end

      it 'fails with Consumer::Unsatisfied' do
        expect { subject.run!(input) }
          .to raise_error(YABFI::Consumer::Unsatisfied)
      end
    end

    context 'when all of the input can be consumed' do
      let(:input) do
        %i(
          succ
          loop
          loop
          prev
          prev
          end
          put
          end
          next
          get
          pred
        )
      end
      let(:expected) do
        [
          [:change_value, 1],
          [
            :loop,
            [
              [
                :loop,
                [
                  [:change_pointer, -2]
                ]
              ],
              [:put, 1]
            ]
          ],
          [:change_pointer, 1],
          [:get, 1],
          [:change_value, -1]
        ]
      end

      it 'returns the syntax forest' do
        expect(subject.run!(input)).to eq(expected)
      end
    end
  end
end
