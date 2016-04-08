require 'rails_helper'

RSpec.describe PrisonVisits::Api do
  subject { described_class.instance }

  # This should be set to the ID of Cardiff prison on the system generating
  # the VCR cassettes. Sadly this will vary from system to system as a result
  # of using UUIDs for prisons.
  let(:cardiff_prison_id) { '0614760e-a773-49c0-a29c-35e743e72555' }

  let(:valid_booking_params) {
    {
      prison_id: cardiff_prison_id,
      prisoner: {
        first_name: "Oscar",
        last_name: "Wilde",
        date_of_birth: Date.new(1980, 12, 31),
        number: "a1234bc"
      },
      visitors: [{
        first_name: "Ada",
        last_name: "Lovelace",
        date_of_birth: Date.new(1970, 11, 30)
      }, {
        first_name: "Charlie",
        last_name: "Chaplin",
        date_of_birth: Date.new(2005, 1, 2)
      }],
      contact_email_address: "ada@test.example.com",
      contact_phone_no: "01154960222",
      slot_options: [
        "2015-01-02T09:00/10:00",
        "2015-01-03T09:00/10:00",
        "2015-01-04T09:00/10:00"
      ]
    }
  }

  # Specs use vcr cassettes, no real calls are made
  before do
    WebMock.allow_net_connect!
  end

  describe 'API localisation' do
    it "uses 'en' locale by default", vcr: { cassette_name: 'get_prisons' } do
      subject.get_prisons

      expect(WebMock).
        to have_requested(:get, /api/).
        with(headers: { 'Accept-Language' => 'en' })
    end

    it 'uses the I18n locale', vcr: { cassette_name: 'get_prisons_cy' } do
      I18n.locale = 'cy'

      subject.get_prisons

      expect(WebMock).
        to have_requested(:get, /api/).
        with(headers: { 'Accept-Language' => 'cy' })
    end
  end

  describe 'get_prisons', vcr: { cassette_name: 'get_prisons' } do
    subject { super().get_prisons }

    it 'returns an array of prisons' do
      expect(subject).to be_kind_of(Array)
      expect(subject.first).to be_kind_of(Prison)
    end

    it 'returns prison names and ids' do
      prison = subject.first
      expect(prison.name).to eq('Askham Grange')
      expect(prison.id.length).to eq(36)
    end
  end

  describe 'get_prison', vcr: { cassette_name: 'get_prison' } do
    subject { super().get_prison(cardiff_prison_id) }

    it { is_expected.to be_kind_of(Prison) }

    it 'returns information about the prison' do
      expect(subject.name).to eq("Cardiff")
      expect(subject.address).to eq("Knox Road\nCardiff")
      expect(subject.prison_finder_url).
        to eq("http://www.justice.gov.uk/contacts/prison-finder/cardiff")
    end
  end

  describe 'validate_prisoner', vcr: { cassette_name: 'validate_prisoner' } do
    subject {
      super().validate_prisoner(
        number: 'A1459AE',
        date_of_birth: Date.parse('1976-06-12')
      )
    }

    it 'returns the (raw) validation response' do
      expect(subject).to eq('valid' => true)
    end
  end

  describe 'get_slots', vcr: { cassette_name: 'get_slots' } do
    subject {
      super().get_slots(
        prison_id: cardiff_prison_id,
        prisoner_number: 'a1234bc',
        prisoner_dob: Date.parse('1970-01-01')
      )
    }

    it 'returns an array of concrete slots' do
      expect(subject).to be_kind_of(Array)
      expect(subject.first).to be_kind_of(ConcreteSlot)
    end

    it 'returns sensible looking concrete slots' do
      expect(subject.first.iso8601).to eq("2016-04-08T13:30/14:30")
    end
  end

  describe 'request_visit', vcr: { cassette_name: 'request_visit' } do
    subject { super().request_visit(valid_booking_params) }

    before do
      I18n.locale = 'cy'
    end

    it { is_expected.to be_kind_of(Visit) }

    it 'returns the UUID of the visit booking' do
      expect(subject.id.length).to eq(36)
    end

    it 'returns the id of the prison' do
      expect(subject.prison_id).to eq(cardiff_prison_id)
    end

    it 'returns a list of the requested slots' do
      expect(subject.slots.first.iso8601).to eq("2015-01-02T09:00/10:00")
    end

    it 'returns the booking contact email address' do
      expect(subject.contact_email_address).to eq("ada@test.example.com")
    end
  end

  describe 'get_visit', vcr: { cassette_name: 'get_visit' } do
    subject { super().get_visit(visit_id) }

    let(:visit_id) {
      # Create a visit to use in specs
      described_class.instance.request_visit(valid_booking_params).id
    }

    it { is_expected.to be_kind_of(Visit) }

    it 'returns the processing state of the visit booking' do
      expect(subject.processing_state).to eq('requested')
    end
  end

  describe 'cancel_visit', vcr: { cassette_name: 'cancel_visit' } do
    subject { super().cancel_visit(visit_id) }

    let(:visit_id) {
      # Create a visit to use in specs
      described_class.instance.request_visit(valid_booking_params).id
    }

    it { is_expected.to be_kind_of(Visit) }

    it 'returns the processing state of the visit booking' do
      expect(subject.processing_state).to eq('withdrawn')
    end
  end

  describe 'create_feedback', vcr: { cassette_name: 'create_feedback' } do
    let(:feedback_attrs) {
      {
        body: 'the feedback',
        email_address: 'user@example.com',
        referrer: 'referrer',
        user_agent: 'user agent'
      }
    }

    let(:feedback_submission) { FeedbackSubmission.new(feedback_attrs) }

    it 'makes a request to the api' do
      expect(subject.create_feedback(feedback_submission)).to be_nil
      expect(WebMock).to have_requested(:post, %r{\/api\/feedback\.json}).
        with(body: JSON.generate(feedback: feedback_attrs))
    end
  end
end
