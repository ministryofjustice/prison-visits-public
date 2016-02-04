require 'rails_helper'

RSpec.describe SlotsStep, type: :model do
  describe 'validation of options' do
    subject { described_class.new }

    let(:slot) { ConcreteSlot.new(2015, 1, 2, 9, 0, 10, 0) }
    let(:booking_constraints) {
      instance_double(BookingConstraints,
        on_slots: BookingConstraints::SlotConstraints.new([slot])
                     )
    }

    before do
      allow(BookingConstraints).to receive(:new).and_return booking_constraints
    end

    describe 'option_0' do
      it 'is valid if the slot exists' do
        subject.option_0 = '2015-01-02T09:00/10:00'
        subject.validate
        expect(subject.errors).not_to have_key(:option_0)
      end

      it 'is invalid if the slot does not exist' do
        subject.option_0 = '2015-01-02T09:00/11:00'
        subject.validate
        expect(subject.errors).to have_key(:option_0)
      end

      it 'is invalid if empty' do
        subject.option_0 = ''
        subject.validate
        expect(subject.errors).to have_key(:option_0)
      end
    end

    describe 'option_1' do
      it 'is valid if the slot exists' do
        subject.option_1 = '2015-01-02T09:00/10:00'
        subject.validate
        expect(subject.errors).not_to have_key(:option_1)
      end

      it 'is invalid if the slot does not exist' do
        subject.option_1 = '2015-01-02T09:00/11:00'
        subject.validate
        expect(subject.errors).to have_key(:option_1)
      end

      it 'is valid if empty' do
        subject.option_1 = ''
        subject.validate
        expect(subject.errors).not_to have_key(:option_1)
      end
    end

    describe 'option_2' do
      it 'is valid if the slot exists' do
        subject.option_2 = '2015-01-02T09:00/10:00'
        subject.validate
        expect(subject.errors).not_to have_key(:option_2)
      end

      it 'is invalid if the slot does not exist' do
        subject.option_2 = '2015-01-02T09:00/11:00'
        subject.validate
        expect(subject.errors).to have_key(:option_2)
      end

      it 'is valid if empty' do
        subject.option_2 = ''
        subject.validate
        expect(subject.errors).not_to have_key(:option_2)
      end
    end
  end
end
