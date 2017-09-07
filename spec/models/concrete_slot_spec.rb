RSpec.describe ConcreteSlot do
  subject {
    described_class.new(2015, 10, 23, 14, 0, 15, 30)
  }

  describe 'parse' do
    it 'parses from an ISO 8601 representation' do
      expect(described_class.parse('2015-10-23T14:00/15:30')).to eq(subject)
    end

    it 'raises an ArgumentError if parsing fails' do
      expect {
        described_class.parse('JUNK')
      }.to raise_exception(ArgumentError)
    end
  end

  describe 'iso8601' do
    it 'generates an ISO 8601 representation' do
      expect(subject.iso8601).to eq('2015-10-23T14:00/15:30')
    end
  end

  describe 'to_date' do
    it 'generates a date object' do
      expect(subject.to_date).to eq(Date.new(2015, 10, 23))
    end
  end

  describe 'on?' do
    it 'returns true if slots can be booked on requested date' do
      expect(subject.on?(Date.new(2015, 10, 23))).to be true
    end

    it 'returns false if slots cannot be booked on requested date' do
      expect(subject.on?(Date.new(2015, 10, 24))).to be false
    end
  end

  describe 'begin_at' do
    subject {
      super().begin_at
    }

    it { is_expected.to be_a(Time) }
    it { is_expected.to have_attributes(utc_offset: 0) }
    it { is_expected.to have_attributes(year: 2015, month: 10, day: 23) }
    it { is_expected.to have_attributes(hour: 14, min: 0, sec: 0) }
  end

  describe 'end_at' do
    subject {
      super().end_at
    }

    it { is_expected.to be_a(Time) }
    it { is_expected.to have_attributes(utc_offset: 0) }
    it { is_expected.to have_attributes(year: 2015, month: 10, day: 23) }
    it { is_expected.to have_attributes(hour: 15, min: 30, sec: 0) }
  end

  describe 'duration' do
    it 'is the difference between begin and end times in seconds' do
      expect(subject.duration).to eq(5400)
    end
  end

  describe 'sorting (<=>)' do
    it 'sorts slots according to their start time and slot length' do
      earlier_slot = described_class.new(2015, 10, 23, 14, 0, 18, 30)
      later_slot   = described_class.new(2015, 10, 23, 17, 0, 17, 30)
      later_but_longer = described_class.new(2015, 10, 23, 17, 0, 18, 00)

      expect(earlier_slot).to be < later_slot
      expect(later_slot).to be < later_but_longer
    end

    it 'slots with the same date and slot are equal' do
      slot1 = described_class.new(2015, 10, 23, 14, 0, 18, 30)
      slot2 = described_class.new(2015, 10, 23, 14, 0, 18, 30)

      expect(slot1).to eq(slot2)
    end

    it 'slots of the same date but different slot are not equal' do
      slot1 = described_class.new(2015, 10, 23, 14, 0, 18, 30)
      slot2 = described_class.new(2015, 10, 23, 14, 0, 19, 30)

      expect(slot1).to_not eq(slot2)
    end
  end
end
