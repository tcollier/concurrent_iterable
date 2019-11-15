RSpec.describe ConcurrentIterable::Iterator do
  Timer = Struct.new(:start_time, :end_time)

  def create_timer
    timer = Timer.new(Time.now)
    sleep 0.001
    timer.end_time = Time.now
    timer
  end

  describe '#each' do
    subject { described_class.new([1, 2], concurrency: concurrency) }

    let(:concurrency) { 2 }

    it 'yields every item in the iterable' do
      yielded = Concurrent::Array.new
      subject.each { |item| yielded << item }
      expect(yielded).to match_array([1, 2])
    end

    it 'yields items in parallel' do
      timers = Concurrent::Hash.new
      subject.each { |item| timers[item] = create_timer }
      expect(timers[1].start_time).to be < timers[2].end_time
      expect(timers[2].start_time).to be < timers[1].end_time
    end

    context 'when the iterable has more items that the concurrency' do
      let(:concurrency) { 1 }

      it 'yields in groups based on concurrency' do
        timers = Concurrent::Hash.new
        subject.each { |item| timers[item] = create_timer }
        expect(timers[1].end_time).to be < timers[2].start_time
      end
    end
  end
end
