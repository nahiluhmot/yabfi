lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yabfi'
require 'pry'

RSpec.configure do |config|
  config.around(:each) do |example|
    if ENV['NO_RESCUE'] == 'true'
      example.run
    else
      Pry.rescue do
        err = example.run
        pending = err.is_a?(RSpec::Core::Pending::PendingExampleFixedError)
        Pry.rescued(err) if err && !pending && $stdin.tty? && $stdout.tty?
      end
    end
  end
end
