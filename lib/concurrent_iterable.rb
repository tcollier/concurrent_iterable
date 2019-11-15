require 'concurrent_iterable/config'
require 'concurrent_iterable/iterator'
require 'concurrent_iterable/version'

module ConcurrentIterable
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end
  end
end
