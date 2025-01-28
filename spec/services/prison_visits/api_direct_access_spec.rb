require 'rails_helper'

RSpec.describe PrisonVisits::Api do
  before do
    Rails.configuration.use_staff_api_old = Rails.configuration.use_staff_api
    Rails.configuration.use_staff_api = false
  end

  after do
    Rails.configuration.use_staff_api = Rails.configuration.use_staff_api_old
  end

  let(:valid_visit) {
    {
      id: 1,
      human_id: 1,
      processing_state: :current,
      prison_id: 1,
      confirm_by: :person,
      contact_email_address: 'example@example.com',
      slots: [Date.parse("12/12/2000")],
      slot_granted: Date.parse("12/12/2000"),
      cancellation_reasons: [],
      cancelled_at: Time.now,
      can_cancel: true,
      can_withdraw: true,
      visitors: [create(:staff_visitor)]
    }
  }

  subject { described_class.instance }

  describe 'get_prisons' do
    before do
      allow(Staff::Prison).to receive(:order).and_return(OpenStruct.new({ all: true }))
    end

    it "returns prisons" do
      expect(subject.get_prisons).to be_truthy
    end
  end

  describe 'get_prison' do
    before do
      allow(Prison).to receive(:new).and_return(true)
      allow(Staff::Prison).to receive(:find).and_return(OpenStruct.new({ all: true }))
    end

    it "returns a prison" do
      expect(subject.get_prison(1)).to be_truthy
    end
  end

  describe 'valid_prisoner' do
    before do
      allow(Staff::PrisonerValidator).to receive(:validate).and_return(true)
    end

    it "validates prisoner" do
      expect(subject.validate_prisoner(number: 1, date_of_birth: '12/12/2000')).to be_truthy
    end
  end

  describe 'get_slots' do
    before do
      allow(Staff::Slots).to receive(:slots).and_return({ "2024-05-15T13:45/14:45" => [] })
    end

    it "gets slots" do
      expect(subject.get_slots(prison_id: 1, prisoner_number: 1, prisoner_dob: '12/12/2000')).to be_truthy
    end
  end

  describe 'request_visit' do
    before do
      allow_any_instance_of(Staff::VisitsManager).to receive(:create).and_return(OpenStruct.new(valid_visit))
    end

    it "request visit" do
      expect(subject.request_visit(prison_id: 1, prisoner_number: 1, prisoner_dob: '12/12/2000')).to be_a(Visit)
    end
  end

  describe 'get_visit' do
    before do
      allow(Staff::Visit).to receive(:where).and_return([OpenStruct.new(valid_visit)])
    end

    it "gets visit" do
      expect(subject.get_visit(prison_id: 1, prisoner_number: 1, prisoner_dob: '12/12/2000')).to be_a(Visit)
    end
  end

  describe 'cancel_visit' do
    before do
      allow_any_instance_of(Staff::VisitsManager).to receive(:destroy).and_return(OpenStruct.new(valid_visit))
    end

    it "gets visit" do
      expect(subject.cancel_visit(1)).to be_a(Visit)
    end
  end
end
