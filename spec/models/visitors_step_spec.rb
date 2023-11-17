require 'rails_helper'

RSpec.describe VisitorsStep do
  subject { described_class.new(processor:) }

  let(:processor) { StepsProcessor.new({}, 'en') }

  let(:booking_constraints) {
    instance_double(BookingConstraints, on_visitors: visitor_constraints)
  }
  let(:prison) {
    instance_double(Prison, id: '123', adult_age: 18, max_visitors: 6)
  }
  let(:visitor_constraints) {
    BookingConstraints::VisitorConstraints.new(prison)
  }
  let(:adult) {
    {
      first_name: 'John',
      last_name: 'Johnson',
      date_of_birth: { day: '3', month: '4', year: '1990' }
    }
  }
  let(:adult_dob) { Date.parse('1990-04-03') }
  let(:child_13) {
    {
      first_name: 'Jim',
      last_name: 'Johnson',
      date_of_birth: {
        day: '1', month:  '12', year:  '2002' # 13 today
      }
    }
  }
  let(:child_13_dob) { Date.parse('2002-12-01') }
  let(:child_12) {
    {
      first_name: 'Jessica',
      last_name: 'Johnson',
      date_of_birth: {
        day: '2', month:  '12', year:  '2002' # 13 tomorrow
      }
    }
  }
  let(:child_12_dob) { Date.parse('2002-12-02') }
  let(:blank_visitor) {
    {
      first_name: '',
      last_name: '',
      date_of_birth: { day: '', month: '', year: '' }
    }
  }
  let(:invalid_visitor) {
    {
      first_name: '',
      last_name: 'Johnson',
      date_of_birth: { day: '3', month: '4', year: '1990' }
    }
  }

  before do
    allow(processor).to receive(:booking_constraints).and_return(booking_constraints)
    allow(processor).to receive(:prison).and_return(prison)
    allow(pvb_api).to receive(:validate_visitors).and_return('valid' => true)
  end

  around do |example|
    travel_to Date.new(2015, 12, 1) do
      example.call
    end
  end

  describe "email_address=" do
    it 'strips whitespace' do
      subject.email_address = ' email@example.com '
      expect(subject.email_address).to eq('email@example.com')
    end
  end

  describe "email_address_confirmation=" do
    it 'strips whitespace' do
      subject.email_address_confirmation = ' email@example.com '
      expect(subject.email_address_confirmation).to eq('email@example.com')
    end
  end

  describe 'backfilled_visitors' do
    it 'includes supplied visitors' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'date_of_birth' => { 'day' => '1', 'month' => '2', 'year' => '1980' }
        },
        '1' => {
          'first_name' => 'John',
          'last_name' => 'Johnson',
          'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
        }
      }

      first_visitor = subject.backfilled_visitors[0]
      expect(first_visitor.first_name).to eq('Bob')
      expect(first_visitor.last_name).to eq('Roberts')
      expect(first_visitor.date_of_birth.to_date).to eq(Date.new(1980, 2, 1))

      second_visitor = subject.backfilled_visitors[1]
      expect(second_visitor.first_name).to eq('John')
      expect(second_visitor.last_name).to eq('Johnson')
      expect(second_visitor.date_of_birth.to_date).to eq(Date.new(1990, 4, 3))
    end

    it 'returns blank visitors to make up 6' do
      subject.visitors_attributes = {}
      expect(subject.backfilled_visitors.count).to eq(6)
    end

    it 'includes and validates one visitor if none supplied' do
      subject.visitors_attributes = {}
      subject.valid?
      expect(subject.backfilled_visitors[0].errors).not_to be_empty
    end

    it 'does not validate blank additional visitors' do
      subject.visitors_attributes = {
        '0' => blank_visitor,
        '1' => blank_visitor
      }
      subject.valid?
      expect(subject.backfilled_visitors[1].errors).to be_empty
    end
  end

  describe 'additional_visitor_count' do
    it 'is one less than the number of visitors supplied' do
      subject.visitors = [adult, child_12]
      expect(subject.additional_visitor_count).to eq(1)
    end
  end

  describe 'visitors' do
    it 'returns only visitors assigned with at least one field' do
      subject.visitors_attributes = {
        '0' => {
          'first_name' => 'Bob',
          'last_name' => 'Roberts',
          'date_of_birth' => { 'day' => '1', 'month' => '2', 'year' => '1980' }
        },
        '1' => {
          'first_name' => '',
          'last_name' => '',
          'date_of_birth' => { 'day' => '3', 'month' => '4', 'year' => '1990' }
        },
        '2' => {
          'first_name' => '',
          'last_name' => '',
          'date_of_birth' => { 'day' => '', 'month' => '', 'year' => '' }
        }
      }

      expect(subject.visitors.count).to eq(2)
    end

    it 'always returns at least one visitor' do
      subject.visitors_attributes = {}
      expect(subject.visitors.count).to eq(1)
    end
  end

  describe 'valid?' do
    before do
      subject.email_address = 'user@test.example.com'
      subject.email_address_confirmation = 'user@test.example.com'
      subject.phone_no = '07900112233'
    end

    it 'is true if the step is valid and all visitors are valid' do
      subject.visitors = [adult, adult]
      expect(subject).to be_valid
    end

    it 'is false if a visitor is invalid' do
      subject.visitors = [adult, invalid_visitor]
      expect(subject).not_to be_valid
    end

    it 'is false if there are no visitors' do
      subject.visitors = []
      expect(subject).not_to be_valid
      expect(subject.errors[:general]).to eq(
        ["There must be at least 1 visitor"]
      )
    end

    it 'is invalid if there are too many visitors' do
      subject.visitors = [adult] * 3 + [child_12] * 4
      expect(pvb_api).to receive(:validate_visitors).with(
        prison_id: '123',
        lead_date_of_birth: adult_dob,
        dates_of_birth: [adult_dob] * 3 + [child_12_dob] * 4
      ).and_return(
        'valid' => false,
        'errors' => ['too_many_visitors']
      )
      expect(subject).not_to be_valid
      expect(subject.errors).to have_key(:general)
      expect(subject.errors[:general]).to eq([
        "You can book a maximum of 6 visitors"
      ])
    end

    it 'validates all objects even if one is invalid' do
      subject.email_address = 'invalid'
      subject.visitors = [invalid_visitor, invalid_visitor]
      subject.valid?
      expect(subject.backfilled_visitors[0].errors).not_to be_empty
      expect(subject.backfilled_visitors[1].errors).not_to be_empty
      expect(subject.errors).not_to be_empty
    end

    it 'does not call validation API if a DOB is missing' do
      adult_without_dob = adult.tap { |a| a.delete(:date_of_birth) }
      subject.visitors = [adult_without_dob]

      expect(pvb_api).not_to receive(:validate_visitors)
      expect(subject).not_to be_valid
      expect(subject.errors[:base]).to eq(
        ["One or more visitors are invalid"]
      )
    end

    it 'is invalid if it is not a phone number' do
      subject.phone_no = 'abcedfghijk'
      expect(subject).to_not be_valid
      expect(subject.errors[:phone_no]).to_not be_empty
    end

    it 'is invalid if email_address confirmation does not match email address' do
      subject.email_address_confirmation = 'blah@thing.com'
      subject.email_address_confirmation = 'blahblah@thing.com'
      expect(subject).to_not be_valid
      expect(subject.errors[:email_address_confirmation]).to_not be_empty
    end
  end

  context 'with age-related validations' do
    let(:prison) {
      instance_double(Prison, id: '123', adult_age: 13, max_visitors: 6)
    }

    before do
      subject.email_address = 'user@test.example.com'
      subject.email_address_confirmation = 'user@test.example.com'
      subject.phone_no = '07900112233'
    end

    it 'is valid if there is one adult visitor' do
      subject.visitors = [adult]
      expect(subject).to be_valid
      expect(subject.errors).not_to have_key(:general)
    end

    it 'is valid if there are 3 adult and 3 child visitors' do
      subject.visitors = [adult] * 3 + [child_12] * 3
      expect(subject).to be_valid
      expect(subject.errors).not_to have_key(:general)
    end

    it 'is valid with one adult and lots of children' do
      subject.visitors = [adult] + [child_12] * 5
      expect(subject).to be_valid
      expect(subject.errors).not_to have_key(:general)
    end

    it 'is invalid if there are too many visitors over the prisons adult age' do
      subject.visitors = [adult] + [child_13] * 3
      expect(pvb_api).to receive(:validate_visitors).with(
        prison_id: '123',
        lead_date_of_birth: adult_dob,
        dates_of_birth: [adult_dob] + [child_13_dob] * 3
      ).and_return(
        'valid' => false,
        'errors' => ['too_many_adults']
      )
      expect(subject).not_to be_valid
      expect(subject.errors[:general]).to eq([
        'You can book a maximum of 3 visitors over the age of 13 on this visit'
      ])
    end

    it 'is invalid if the lead-visitor is not an (actual) adult' do
      subject.visitors = [child_13] + [adult]
      expect(pvb_api).to receive(:validate_visitors).with(
        prison_id: '123',
        lead_date_of_birth: child_13_dob,
        dates_of_birth: anything
      ).and_return(
        'valid' => false,
        'errors' => ['lead_visitor_age']
      )
      expect(subject).not_to be_valid
      expect(subject.visitors.first.errors[:date_of_birth]).to eq([
        'The person requesting the visit must be over the age of 18'
      ])
    end
  end
end
