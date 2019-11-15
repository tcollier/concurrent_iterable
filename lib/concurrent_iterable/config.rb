module ConcurrentIterable
  class Config
    DEFAULT_CONCURRENCY = 10

    attr_accessor :concurrency

    def initialize(concurrency: DEFAULT_CONCURRENCY)
      @concurrency = concurrency
    end
  end
end
