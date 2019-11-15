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

    def detect(&block)
      result = nil
      iterable.each_slice(concurrency).each.with_index do |group, group_index|
        results = Concurrent::Array.new(group.length)
        group.length.times.map do |index|
          Concurrent::Promises.future(executor) do
            results[index] = yield group[index]
          end
        end.each(&:wait!)
        found_index = results.index(&:itself)
        if found_index
          result = iterable[group_index * concurrency + found_index]
          break
        end
      end
      result
    end

    def select(&block)
      results = []
      iterable.each_slice(concurrency).each do |group|
        group_evals = Concurrent::Array.new(group.length)
        group.length.times.map do |index|
          Concurrent::Promises.future(executor) do
            group_evals[index] = yield group[index]
          end
        end.each(&:wait!)
        group_evals.each.with_index do |eval, index|
          results << group[index] if eval
        end
      end
      results
    end

    private

    attr_reader :iterable, :concurrency, :executor
  end
end
