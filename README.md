# Enforce MySQL Version

[![Build
Status](https://travis-ci.org/pipt/enforce_mysql_version.png?branch=master)](https://travis-ci.org/pipt/enforce_mysql_version)

This gem will allow you to prevent your rails app from starting unless
the version of MySQL it's running against is a specific major/minor
version.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "enforce_mysql_version", require: "5.6"
```

And then execute:

    $ bundle

## Usage

Adding the gem to your `Gemfile` as shown in the installation
instructions is all you need to do. MySQL versions that can be required
are `5.5`, `5.6` and `5.7`. If you don't provide a required version in
your `Gemfile`, this gem will have no effect.

## Development

After checking out the repo, run `bundle` to install ruby dependecies. Run `docker-compose up` to install and start versions `5.5`, `5.6` and `5.7` of MySQL. Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pipt/enforce_mysql_version.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

