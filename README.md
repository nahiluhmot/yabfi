# YABFI [![Build Status](https://travis-ci.org/nahiluhmot/yabfi.svg)](https://travis-ci.org/nahiluhmot/yabfi) [![Gem Version](https://badge.fury.io/rb/yabfi.svg)](http://badge.fury.io/rb/yabfi)

Yet another YABFI interpreter written in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yabfi'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install yabfi
```

## Usage

This gem can either be used via native Ruby calls or from the command line.
To use the gem from ruby, a top level method, `.eval!` is provided. By default,
than method will use `$stdin` as input, `$stdout` as output, and `0` as the
value to return when `EOF` is reached.

Below is an execution of a clone of the standard Unix `cat` utility.

```ruby
> cat = ',[.,]'
> YABFI.eval!(cat)
sample input
^D
sample input
# => nil
```

The program's `input`, `output`, and `eof` may all be set via keyword arguments to this method.

The gem also exports an executable called `yabfi`.
Here is some example usage of the same cat program from above:

```shell
$ yabfi -x',[,.]'
hello, world
^D
hello, world
$
```

Execute `yabfi -h` for a full list of options.

## Development

After checking out the repo, run `bundle install` to install dependencies.
Then, run `bundle exec rake shell` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/nahiluhmot/yabfi/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
