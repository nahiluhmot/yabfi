require 'spec_helper'

describe Brainfuck do
  it 'has a version number' do
    expect(Brainfuck::VERSION).to_not be(nil)
  end

  describe '.eval' do
    let(:commands) { '' }
    let(:input) { StringIO.new }
    let(:output) { StringIO.new }
    let(:eof) { 0 }

    before { subject.eval!(commands, input, output, eof) }

    context 'when the program is "Hello World"' do
      let(:commands) do
        <<-EOS
          >++++++++[<+++++++++>-]<.>>+>+>++>[-]+<[>[->+<<++++>]<<]>.+++++++..+++
          .>>+++++++.<<<[[-]<[-]>]<+++++++++++++++.>>.+++.------.--------.>>+.>+
          +++.
        EOS
      end

      it 'evaluates the commands' do
        expect(output.string).to eq("Hello World!\n")
      end
    end

    context 'when the program is "cat"' do
      let(:commands) { ',[.,]' }
      let(:string) { 'Howdy ho! Cowby hat!' }
      let(:input) { StringIO.new(string) }

      it 'evaluates the commands' do
        expect(output.string).to eq(string)
      end
    end

    context 'when the program is wc' do
      let(:commands) do
        <<-EOS
          >>>+>>>>>+>>+>>+[<<],[
              -[-[-[-[-[-[-[-[<+>-[>+<-[>-<-[-[-[<++[<++++++>-]<
                  [>>[-<]<[>]<-]>>[<+>-[<->[-]]]]]]]]]]]]]]]]
              <[-<<[-]+>]<<[>>>>>>+<<<<<<-]>[>]>>>>>>>+>[
                  <+[
                      >+++++++++<-[>-<-]++>[<+++++++>-[<->-]+[+>>>>>>]]
                      <[>+<-]>[>>>>>++>[-]]+<
                  ]>[-<<<<<<]>>>>
              ],
          ]+<++>>>[[+++++>>>>>>]<+>+[[<++++++++>-]<.<<<<<]>>>>>>>>]
        EOS
      end
      let(:input) { StringIO.new("one two\nthree four\n") }

      it 'evaluates the commands' do
        expect(output.string).to eq("\t2\t4\t19\n")
      end
    end
  end
end
