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

  describe '#map' do
    subject { described_class.new([1, 2], concurrency: concurrency) }

    let(:concurrency) { 2 }

    it 'yields every item in the iterable' do
      mapped = subject.map(&:itself)
      expect(mapped).to eq([1, 2])
    end

    it 'maintains order in the iterable' do
      def sleeper(item)
        duration = item == 1 ? 0.01 : 0.001
        sleep duration
        item
      end
      mapped = subject.map(&method(:sleeper))
      expect(mapped).to eq([1, 2])
    end

    it 'maps items in parallel' do
      mapped = subject.map { |item| create_timer }
      expect(mapped[0].start_time).to be < mapped[1].end_time
      expect(mapped[1].start_time).to be < mapped[0].end_time
    end

    context 'when the iterable has more items that the concurrency' do
      let(:concurrency) { 1 }

      it 'yields in groups based on concurrency' do
        mapped = subject.map { |item| create_timer }
        expect(mapped[0].end_time).to be < mapped[1].start_time
      end
    end
  end
end
