require 'rails_helper'

RSpec.describe BookingConstraints, type: :model do
  subject { described_class.new(params) }

  let(:params) {
    {
      prison: prison,
      prisoner_number: prisoner_number,
      prisoner_dob: prisoner_dob
    }
  }
  let(:prison) {
    instance_double(Prison, id: '123', adult_age: 13, max_visitors: 6)
  }
  let(:prisoner_number) { 'a1234bc' }
  let(:prisoner_dob) { Date.parse('1970-01-01') }

  describe 'on visitors' do
    subject { super().on_visitors }

    it 'reads the adult_age from the prison (which comes from the API)' do
      expect(prison).to receive(:adult_age)
      expect(subject.adult_age).to eq(13)
    end

    it 'reads the max_visitors from the prison (which comes from the API)' do
      expect(prison).to receive(:max_visitors)
      expect(subject.max_visitors).to eq(6)
    end
  end

  describe 'on slots' do
    subject { super().on_slots }

    before do
      allow(pvb_api).to receive(:get_slots).and_return([
        CalendarSlot.new(slot: ConcreteSlot.new(2015, 1, 2, 9, 0, 10, 0)),
        CalendarSlot.new(slot: ConcreteSlot.new(2015, 1, 4, 9, 0, 10, 0)),
        CalendarSlot.new(slot: ConcreteSlot.new(2015, 1, 3, 9, 0, 10, 0))
      ])
    end

    it 'fetches available slots from the API' do
      expect(pvb_api).to receive(:get_slots).
        with(
          prison_id: prison.id,
          prisoner_number: prisoner_number,
          prisoner_dob: prisoner_dob
        )

      subject
    end

    it 'allows checking whether a date is bookable' do
      expect(subject.bookable_date?(Date.new(2015, 1, 2))).to be true
      expect(subject.bookable_date?(Date.new(2015, 2, 2))).to be false
    end

    it 'allows checking last bookable date' do
      expect(subject.last_bookable_date).to eq(Date.new(2015, 1, 4))
    end

    it 'can return whether there are available slots' do
      expect(subject.bookable_slots?).to be(true)
    end
  end
end
