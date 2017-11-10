require 'rails_helper'

RSpec.describe SlotsStep, type: :model do
  subject(:instance) { described_class.new }

  let(:slot0) { ConcreteSlot.parse('2015-01-02T09:00/10:00') }
  let(:slot1) { ConcreteSlot.parse('2015-01-02T11:00/12:00') }
  let(:slot2) { ConcreteSlot.parse('2015-01-03T09:00/10:00') }

  let(:prisoner_step) do
    instance_double(PrisonerStep, first_name: 'John')
  end

  let(:processor) do
    instance_double(StepsProcessor,
      booking_constraints: booking_constraints,
      prisoner_step: prisoner_step)
  end

  let(:calendar_slots) do
    [
      CalendarSlot.new(slot: slot0),
      CalendarSlot.new(slot: slot1),
      CalendarSlot.new(slot: slot2)
    ]
  end

  let(:booking_constraints) do
    instance_double(BookingConstraints, on_slots: SlotConstraints.new(calendar_slots))
  end

  before do
    allow(instance).to receive(:processor).and_return(processor)
    allow(processor).to receive(:booking_constraints).and_return(booking_constraints)
  end

  describe 'validation of options' do
    it 'is valid if the option is a correctly formatted time range' do
      subject.option_0 = '2015-01-02T09:00/10:00'
      expect(subject).to be_valid
      expect(subject.errors).not_to have_key(:option_0)
    end

    it 'is invalid if the option is not a time range' do
      subject.option_0 = '2015-01-02T09:00'
      expect(subject).not_to be_valid
      expect(subject.errors).to have_key(:option_0)
    end

    it 'is invalid if option_0 is empty' do
      subject.option_0 = ''
      subject.valid?
      expect(subject.errors).to have_key(:option_0)
    end

    it 'is invalid if the slots are not bookable slots' do
      subject.option_0 = '2015-01-02T09:00/11:00'
      subject.option_1 = '2015-01-02T09:00/12:00'
      subject.option_2 = '2015-01-02T09:00/13:00'
      subject.valid?
      expect(subject.errors).to have_key(:option_0)
      expect(subject.errors).to have_key(:option_1)
      expect(subject.errors).to have_key(:option_2)
    end

    it 'is valid if option_1 is empty' do
      subject.option_1 = ''
      subject.valid?
      expect(subject.errors).not_to have_key(:option_1)
    end

    it 'is valid if option_2 empty' do
      subject.option_2 = ''
      subject.valid?
      expect(subject.errors).not_to have_key(:option_2)
    end
  end

  context 'with #options_available?' do
    shared_examples :options_are_available do
      it 'options are available' do
        expect(subject.options_available?).to eq(true)
      end
    end

    shared_examples :options_are_not_available do
      it 'options are not available' do
        expect(subject.options_available?).to eq(false)
      end
    end

    context 'when posted from Prisoner page' do
      it_behaves_like :options_are_available
    end

    context 'when posted from Slot 1 page' do
      before do
        subject.option_0 = slot0.iso8601
        subject.currently_filling = '0'
      end

      context 'with bookable slots available' do
        before do
          expect(subject).
            to receive(:available_bookable_slots?).
            and_return(true)
        end

        it_behaves_like :options_are_available
      end

      context 'with no bookable slots available' do
        before do
          expect(instance).
            to receive(:available_bookable_slots?).
            and_return(false)
        end

        it_behaves_like :options_are_not_available
      end
    end

    context 'when posting from Slot 1 page from save and skip link' do
      before do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.currently_filling = '0'
        subject.skip_remaining_slots = 'true'
      end

      it_behaves_like :options_are_not_available
    end

    context 'when posting from Slot 2 page' do
      before do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.option_1 = '2015-01-03T09:00/10:00'
        subject.currently_filling = '1'
      end

      context 'with options available' do
        before do
          expect(instance).
            to receive(:available_bookable_slots?).
            and_return(true)
        end
        it_behaves_like :options_are_available
      end

      context 'with no options available' do
        before do
          expect(instance).
            to receive(:available_bookable_slots?).
            and_return(false)
        end

        it_behaves_like :options_are_not_available
      end
    end

    context 'when posting from Slot 3 page having not filled slot 3' do
      before do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.option_1 = '2015-01-03T09:00/10:00'
        subject.currently_filling = '2'
      end

      it_behaves_like :options_are_not_available
    end

    context 'when posting from visitor page' do
      before do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.option_1 = '2015-01-03T09:00/10:00'
        subject.currently_filling = '2'
      end

      it_behaves_like :options_are_not_available
    end

    context 'when posting from Review slot 2 link on review page' do
      before do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.option_1 = '2015-01-03T09:00/10:00'
        subject.review_slot = '1'
      end

      it_behaves_like :options_are_available
    end

    context 'when posting from Slot 2 page when reviewing' do
      before do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.option_1 = '2015-01-05T09:00/10:00'
        subject.review_slot = '1'
        subject.currently_filling = '1'
      end

      it_behaves_like :options_are_not_available
    end

    context 'when posting from review page with absent slots' do
      before do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.option_1 = '2015-01-05T09:00/10:00'
        subject.option_2 = ''
        subject.skip_remaining_slots = 'true'
      end

      it_behaves_like :options_are_not_available
    end
  end

  context 'with #valid_options' do
    let(:booking_constraints) do
      instance_double(
        BookingConstraints,
        on_slots: SlotConstraints.new(
          [CalendarSlot.new(slot: slot0)]
        )
      )
    end

    before do
      allow(instance).
        to receive(:processor).and_return(processor)

      allow(processor).to receive(:booking_constraints).
        and_return(booking_constraints)

      subject.option_0 = option_0
      subject.option_1 = option_1
      subject.option_2 = option_2

      subject.valid?
    end

    context 'when no valid options' do
      let(:option_0) { 'foobar' }
      let(:option_1) { nil }
      let(:option_2) { nil }

      it 'return empty array' do
        expect(subject.valid_options).to eq([])
      end
    end

    context 'with some valid options' do
      let(:option_0) { slot0.to_s }
      let(:option_1) { 'foobar' }
      let(:option_2) { nil }

      it 'returns the valid slot' do
        expect(subject.valid_options).to eq([slot0])
      end
    end
  end

  context ' when #next_slot_to_fill' do
    context 'when review slot is set' do
      before do
        subject.review_slot = review_slot
        allow(subject).to receive(:valid?).and_return(true)
      end

      let(:review_slot) { 'foo' }

      it 'returns review slot' do
        expect(subject.next_slot_to_fill).to eq review_slot
      end
    end

    context 'with 3 valid slots' do
      before do
        subject.option_0 = slot0.iso8601
        subject.option_1 = slot1.iso8601
        subject.option_2 = slot2.iso8601
      end

      it 'returns nil' do
        expect(subject.next_slot_to_fill).to eq(nil)
      end
    end

    context 'with less than 3 valid slots' do
      before do
        subject.option_0 = slot0.iso8601
        subject.option_1 = slot1.iso8601
      end

      it 'returns the number of slots' do
        expect(subject.next_slot_to_fill).to eq('2')
      end
    end

    context 'with an unbookable selection' do
      let(:unbookable) { '2017-01-01T11:00/12:00' }

      before do
        subject.option_0 = slot0.iso8601
        subject.option_1 = slot1.iso8601
        subject.option_2 = unbookable
      end

      it "returns '0'" do
        expect(subject.next_slot_to_fill).to eq('0')
      end
    end
  end

  context 'when #skip_remaining_slots?' do
    context 'with no errors' do
      context 'when user sets skip_remaining_slots' do
        before do
          subject.skip_remaining_slots = 'true'
        end

        it 'returns true' do
          expect(subject.skip_remaining_slots?).to eq(true)
        end
      end

      context 'when user does not set skip_remaining_slots' do
        it 'returns false' do
          expect(subject.skip_remaining_slots?).to eq(false)
        end
      end
    end

    context 'with errors' do
      before do
        subject.option_0 = 'goofy'
      end

      it 'returns false' do
        expect(subject.skip_remaining_slots?).to eq(false)
      end
    end
  end

  context 'with #unbookable_slots_selected?' do
    subject { instance.unbookable_slots_selected? }

    context 'with no slots selected' do
      before do
        instance.option_0 = nil
        instance.option_1 = nil
        instance.option_2 = nil
      end

      it { is_expected.to eq(false) }
    end

    context 'with some unbookable slots selected' do
      let(:unbookable) { '2017-01-01T10:00/11:00' }

      before do
        instance.option_0 = unbookable
        instance.option_1 = slot1.iso8601
        instance.option_2 = slot2.iso8601
      end

      it { is_expected.to eq(true) }
    end

    context 'with all slots selected bookable' do
      before do
        instance.option_0 = slot0.iso8601
        instance.option_1 = slot1.iso8601
        instance.option_2 = slot2.iso8601
      end

      it { is_expected.to eq(false) }
    end
  end

  context ' when #available_bookable_slots?' do
    let(:booking_constraints) do
      instance_double(BookingConstraints, on_slots: SlotConstraints.new(calendar_slots))
    end

    let(:processor) do
      instance_double(StepsProcessor,
        booking_constraints: booking_constraints,
        prisoner_step: prisoner_step)
    end

    before do
      allow(instance).to receive(:processor).and_return(processor)
      allow(processor).
        to receive(:booking_constraints).
        and_return(booking_constraints)
    end

    subject { instance.available_bookable_slots? }

    context 'when there is no (valid) slot selected' do
      before do
        instance.option_0 = nil
      end

      it { is_expected.to eq(true) }
    end

    context 'with 1 selected slots' do
      before do
        instance.option_0 = slot0.iso8601
      end

      context 'when there are other bookable slots' do
        let(:calendar_slots) do
          [
            CalendarSlot.new(slot: slot0, unavailability_reasons: []),
            CalendarSlot.new(slot: slot1, unavailability_reasons: [])
          ]
        end

        it { is_expected.to eq(true) }
      end

      context 'when the other slots are not bookable' do
        let(:calendar_slots) do
          [
            CalendarSlot.new(slot: slot0, unavailability_reasons: []),
            CalendarSlot.new(slot: slot1, unavailability_reasons: [anything])
          ]
        end

        it { is_expected.to eq(false) }
      end
    end

    context 'with 2 selected slots' do
      before do
        instance.option_0 = slot0.iso8601
        instance.option_1 = slot1.iso8601
      end

      context 'when there are other bookable slots' do
        let(:calendar_slots) do
          [
            CalendarSlot.new(slot: slot0, unavailability_reasons: []),
            CalendarSlot.new(slot: slot1, unavailability_reasons: []),
            CalendarSlot.new(slot: slot2, unavailability_reasons: [])
          ]
        end

        it { is_expected.to eq(true) }
      end

      context 'when the other slots are not bookable' do
        let(:calendar_slots) do
          [
            CalendarSlot.new(slot: slot0, unavailability_reasons: []),
            CalendarSlot.new(slot: slot1, unavailability_reasons: []),
            CalendarSlot.new(slot: slot2, unavailability_reasons: [anything])
          ]
        end

        it { is_expected.to eq(false) }
      end
    end
  end
end
