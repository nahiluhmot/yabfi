require 'spec_helper'

describe YABFI::VirtualMachine do
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }
  let(:eof) { -1 }
  subject { described_class.new(input, output, eof) }

  describe '#execute!' do
    let(:commands) { [] }

    before { subject.load!(commands) }

    context 'when it executes a change_value command' do
      let(:commands) do
        [
          [:change_value, -4],
          [:change_value, 7]
        ]
      end

      it 'changes the value at the memory cursor by the given delta' do
        expect { subject.execute! }
          .to change { subject.state[:current_value] }
          .from(0)
          .to(3)
      end

      it 'advances the program counter by 1' do
        expect { subject.execute! }
          .to change { subject.state[:program_counter] }
          .by(commands.length)
      end
    end

    context 'when it executes a change_pointer command' do
      context 'when the pointer is moved below 0' do
        let(:commands) do
          [
            [:change_pointer, 3],
            [:change_pointer, -4]
          ]
        end

        it 'fails with MemoryOutOfBounds' do
          expect { subject.execute! }
            .to raise_error(described_class::MemoryOutOfBounds)
        end
      end

      context 'when the pointer is moved above 0' do
        let(:commands) do
          [
            [:change_pointer, 100],
            [:change_pointer, -65]
          ]
        end

        it 'moves the cursor' do
          expect { subject.execute! }
            .to change { subject.state[:cursor] }
            .from(0)
            .to(35)
        end

        it 'advances the program counter by 1' do
          expect { subject.execute! }
            .to change { subject.state[:program_counter] }
            .by(commands.length)
        end
      end
    end

    context 'when it executes a get command' do
      context 'when EOF is encountered' do
        let(:commands) do
          [
            [:get, 1]
          ]
        end

        it 'sets the current memory location to the specified EOF value' do
          subject.execute!
          expect(subject.state[:current_value]).to eq(eof)
        end

        it 'advances the program counter by 1' do
          expect { subject.execute! }
            .to change { subject.state[:program_counter] }
            .by(commands.length)
        end
      end

      context 'when EOF is not encountered' do
        let(:input) { StringIO.new('ABC') }
        let(:commands) do
          [
            [:get, 2]
          ]
        end

        it 'sets the current memory localtion to the int value of the input' do
          subject.execute!
          expect(subject.state[:current_value]).to eq('B'.ord)
        end

        it 'advances the program counter by 1' do
          expect { subject.execute! }
            .to change { subject.state[:program_counter] }
            .by(commands.length)
        end
      end
    end

    context 'when it executes a put command' do
      let(:commands) do
        [
          [:change_value, 'E'.ord],
          [:put, 5]
        ]
      end

      it 'prints the current memory location the specified number of times' do
        expect { subject.execute! }
          .to change { output.string }
          .from('')
          .to('EEEEE')
      end

      it 'advances the program counter by 1' do
        expect { subject.execute! }
          .to change { subject.state[:program_counter] }
          .by(commands.length)
      end
    end

    context 'when it executes a branch_if_zero command' do
      context 'when the current memory location is zero' do
        let(:commands) do
          [
            [:branch_if_zero, 5]
          ]
        end

        it 'branches to the specified location' do
          expect { subject.execute! }
            .to change { subject.state[:program_counter] }
            .to(5)
        end
      end

      context 'when the current memory location is not zero' do
        let(:commands) do
          [
            [:change_value, 1],
            [:branch_if_zero, -1],
            [:change_value, 2]
          ]
        end

        it 'advances the program counter by 1' do
          expect { subject.execute! }
            .to change { subject.state[:program_counter] }
            .by(commands.length)
        end
      end
    end

    context 'when it executes a branch_not_zero command' do
      context 'when the current memory location is zero' do
        let(:commands) do
          [
            [:branch_not_zero, -1],
            [:change_value, 1]
          ]
        end

        it 'advances the program counter by 1' do
          expect { subject.execute! }
            .to change { subject.state[:program_counter] }
            .by(commands.length)
        end
      end

      context 'when the current memory location is not zero' do
        let(:commands) do
          [
            [:change_value, 3],
            [:change_value, -1],
            [:branch_not_zero, -1]
          ]
        end

        it 'branches to the specified location' do
          subject.execute!
          expect(subject.state[:memory]).to be_all(&:zero?)
        end
      end
    end

    describe 'when it executes an invalid command' do
      let(:commands) do
        [
          [:bad_command, 1]
        ]
      end

      it 'fails with InvalidCommand' do
        expect { subject.execute! }
          .to raise_error(described_class::InvalidCommand)
      end
    end
  end
end
