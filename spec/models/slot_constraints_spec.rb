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
    describe 'with at least one bookable slot' do
      it 'is true' do
        expect(subject.bookable_slots?).to be true
      end
    end

    describe 'with at least one bookable slot' do
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

  describe '#unavailability_reasons' do
    let(:unbookable_slot_0) do
      CalendarSlot.new(
        slot: ConcreteSlot.parse('2017-02-15T14:15/16:15'),
        unavailability_reasons: ['prisoner_unavailable']
      )
    end

    let(:unbookable_slot_1) do
      CalendarSlot.new(
        slot: ConcreteSlot.parse('2017-02-17T14:15/16:15'),
        unavailability_reasons: ['slot_unavailable']
      )
    end

    let(:unbookable_slot_2) do
      CalendarSlot.new(
        slot: ConcreteSlot.parse('2017-02-16T14:15/16:15'),
        unavailability_reasons: ['prisoner_unavailable']
      )
    end

    let(:unbookable_slot_3) do
      CalendarSlot.new(
        slot: ConcreteSlot.parse('2017-02-19T14:15/16:15'),
        unavailability_reasons: ['slot_unavailable']
      )
    end

    let(:slots) do
      [unbookable_slot_0, unbookable_slot_1, unbookable_slot_2, unbookable_slot_3]
    end

    context 'when a specific slot is provided' do
      it 'checks whether that slot has any unavailability reasons' do
        expect(subject.unavailability_reasons(unbookable_slot_0)).to eq ['prisoner_unavailable']
      end
    end

    context 'when checking all dates within a booking window' do
      it 'checks all dates for unavailability reasons' do
        expect(subject.unavailability_reasons).to eq %w[prisoner_unavailable slot_unavailable]
      end
    end
  end
end
