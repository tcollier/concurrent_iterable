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

    def map(&block)
      result = Concurrent::Array.new(iterable.length)
      iterable.each_slice(concurrency).each.with_index do |group, group_index|
        group.length.times.map do |index|
          Concurrent::Promises.future(executor) do
            result_index = group_index * concurrency + index
            result[result_index] = yield group[index]
          end
        end.each(&:wait!)
      end
      result
    end

    private

    attr_reader :iterable, :concurrency, :executor
  end
end
