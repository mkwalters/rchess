# Rchess

Welcome to Rchess!

Rchess is a command line chess engine for humans.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rchess'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rchess

## Usage

Launch the game:
```
bin/console
```

Enter moves using source/target cells:
```
8 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
7 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
6
5
4
3
2 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
1 ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
  a b c d e f g h
w> e2 e4

8 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
7 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
6
5
4         ♙
3
2 ♙ ♙ ♙ ♙   ♙ ♙ ♙
1 ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
  a b c d e f g h
b>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Tests

Rchess uses Rspec for tests. To run all tests, run `rake spec`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tehsven/rchess.

