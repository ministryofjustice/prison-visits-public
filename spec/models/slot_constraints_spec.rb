require "rails_helper"

RSpec.describe SlotConstraints do
  let(:bookable_slot) do
    CalendarSlot.new(
      slot: ConcreteSlot.parse('2017-02-15T14:15/16:15'),
      unavailability_reasons: []
    )
  end

  let(:other_bookable_slot) do
    CalendarSlot.new(
      slot: ConcreteSlot.parse('2017-02-17T14:15/16:15'),
      unavailability_reasons: []
    )
  end

  let(:unbookable_slot) do
    CalendarSlot.new(
      slot: ConcreteSlot.parse('2017-02-16T14:15/16:15'),
      unavailability_reasons: ['prisoner_unavailable']
    )
  end

  let(:slots) do
    [other_bookable_slot, bookable_slot, unbookable_slot]
  end

  subject { described_class.new(slots) }

  describe '#bookable_date?' do
    describe 'with a date contained the slots' do
      describe 'and the date has not unavailability reasons' do
        it 'is true' do
          expect(subject.bookable_date?(Date.parse('2017-02-15'))).to be true
        end
      end

      describe 'and the date has unavailability reasons' do
        it 'is false' do
          expect(subject.bookable_date?(Date.parse('2017-02-16'))).to be false
        end
      end
    end

    describe 'with a not date contained in the slots' do
      it 'is false' do
        expect(subject.bookable_date?(Date.parse('2017-03-16'))).to be false
      end
    end
  end

  describe '#bookable_slot?' do
    describe 'with an exisiting slot' do
      describe 'which is available' do
        it 'is true' do
          expect(
            subject.bookable_slot?(ConcreteSlot.parse('2017-02-15T14:15/16:15'))
          ).to be true
        end
      end

      describe 'which is not available' do
        it 'is false' do
          expect(
            subject.bookable_slot?(ConcreteSlot.parse('2017-02-16T14:15/16:15'))
          ).to be false
        end
      end
    end

    describe 'without an existing slot' do
      it 'is false' do
        expect(
          subject.bookable_slot?(ConcreteSlot.parse('2017-03-16T14:15/16:15'))
        ).to be false
      end
    end
  end

  describe '#last_bookable_date' do
    it 'retuns the last bookable date' do
      expect(subject.last_bookable_date).to eq(Date.parse('2017-02-17'))
    end
  end

  describe '#bookable_slot?' do
    describe 'with at least ont bookable slot' do
      it 'is true' do
        expect(subject.bookable_slots?).to be true
      end
    end

    describe 'with at least ont bookable slot' do
      describe 'with no bookable slot' do
        let(:slots) do
          [unbookable_slot]
        end

        it 'is false' do
          expect(subject.bookable_slots?).to be false
        end
      end
    end
  end
end
