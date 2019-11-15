require 'concurrent'

module ConcurrentIterable
  class Iterator
    def initialize(iterable, concurrency: ConcurrentIterable.config.concurrency)
      @iterable = iterable
      @concurrency = concurrency
      @executor = Concurrent::FixedThreadPool.new(concurrency)
    end

    def each(&block)
      iterable.each_slice(concurrency).each do |group|
        group.length.times.map do |index|
          Concurrent::Promises.future(executor) { yield group[index] }
        end.each(&:wait!)
      end
    end

    private

    attr_reader :iterable, :concurrency, :executor
  end
end
