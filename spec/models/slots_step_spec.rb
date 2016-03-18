require 'rails_helper'

RSpec.describe SlotsStep, type: :model do
  describe 'validation of options' do
    subject { described_class.new }

    let(:slot) { ConcreteSlot.new(2015, 1, 2, 9, 0, 10, 0) }
    let(:booking_constraints) {
      instance_double(
        BookingConstraints,
        on_slots: BookingConstraints::SlotConstraints.new([slot])
      )
    }

    before do
      allow(BookingConstraints).to receive(:new).and_return booking_constraints
    end

    it 'is valid if the option is a correctly formatted time range' do
      subject.option_0 = '2015-01-02T09:00/10:00'
      subject.validate
      expect(subject).to be_valid
      expect(subject.errors).not_to have_key(:option_0)
    end

    it 'is invalid if the option is not a time range' do
      subject.option_0 = '2015-01-02T09:00'
      subject.validate
      expect(subject).not_to be_valid
      expect(subject.errors).to have_key(:option_0)
    end

    it 'is invalid if option_0 is empty' do
      subject.option_0 = ''
      subject.validate
      expect(subject.errors).to have_key(:option_0)
    end

    it 'is valid if option_1 is empty' do
      subject.option_1 = ''
      subject.validate
      expect(subject.errors).not_to have_key(:option_1)
    end

    it 'is valid if option_2 empty' do
      subject.option_2 = ''
      subject.validate
      expect(subject.errors).not_to have_key(:option_2)
    end
  end
end
