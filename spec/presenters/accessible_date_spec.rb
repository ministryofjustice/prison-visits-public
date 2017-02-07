require "rails_helper"

RSpec.describe AccessibleDate, type: :model do
  let(:attributes) { { year: '2017', month: '12', day: '25' } }
  subject { described_class.new(attributes) }

  it do
    is_expected.to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :month }
    it { is_expected.to validate_presence_of :day }

    context 'with an invalid date' do
      let(:attributes) { { year: '2017', month: '13', day: '25' } }

      it { is_expected.to_not be_valid }
    end

    context 'with no date parts set' do
      let(:attributes) { { year: '', month: '', day: '' } }
      it { is_expected.to be_valid }
    end
  end

  describe '::parse' do
    let(:today) { Time.zone.today }

    describe 'with a date' do
      it 'returns an accessible date' do
        expect(described_class.parse(today)).
          to be_instance_of(described_class)
      end
    end

    describe 'with a hash' do
      let(:date_or_hash) { { day: today.day, month: today.month, year: today.year } }

      it 'returns an accessible date' do
        expect(described_class.parse(date_or_hash)).to be_instance_of(described_class)
      end
    end

    describe 'with a nil value' do
      let(:date_or_hash) { nil }
      it 'returns nothing' do
        expect(described_class.parse(date_or_hash)).to be_instance_of(described_class)
      end
    end
  end
end
