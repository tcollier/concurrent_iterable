[![Build Status](https://travis-ci.com/tcollier/concurrent_iterable.svg?branch=master)](https://travis-ci.com/tcollier/concurrent_iterable)

# ConcurrentIterable

Concurrently iterate through an iterable object

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'concurrent_iterable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install concurrent_iterable

## Usage

### Initializer

Wrap any iterable (e.g. `Array`, `Hash`, or `Set`) in a `ConcurrentIterable::Iterator`
instance to expose the standard enumerable methods that evaluate concurrently

### Methods

The following iterable/enumerable methods are available

##### `#each(&block)`

##### `#map(&block)`

##### `#detect(&block)`

### Examples

```ruby
def fetch_resource(remote_id)
  # slow operation to fetch resource over the network
end

def remote_operation(resource, action)
  # other slow operator to perform a remote action on the resource
end

remote_ids = [1, 2, 3]

ids_iterator = ConcurrentIterable::Iterator.new(remote_ids)
resources = ids_iterator.map(&method(:fetch_resource))

resources_iterator = ConcurrentIterable::Iterator.new(resources)
resources_iterator.each { |resource| remote_operation(resource, :publish) }
```

### Configuration

You can set the configuration globally

```ruby
ConcurrentIterable.configure do |config|
  config.concurrency = <number of concurrent executions, defaults to 10>
end
```

Or on a case-by-case basis

```ruby
ConcurrentIterable::Iterator.new(remote_ids, concurrency: 25).map { ... }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/concurrent_iterable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ConcurrentIterable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/concurrent_iterable/blob/master/CODE_OF_CONDUCT.md).
