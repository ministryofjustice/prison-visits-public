require 'rails_helper'

RSpec.describe PrisonVisits::Client do
  subject {
    described_class.new(Rails.configuration.api_host)
  }

  before do
    # Specs use vcr cassettes, no real calls are made
    WebMock.allow_net_connect!

    # Needs to be set for all the requests, otherwise the recorded request's
    # wont match the valid_uuid matcher. This is just a random but valid UUID.
    RequestStore.store[:request_id] = '5cd2ef1a-4b7e-11e7-a919-92ebcb67fe33'
  end

  describe '#healthcheck' do
    it 'calls the healthcheck endpoint', vcr: { cassette_name: 'healthcheck' } do
      expect(subject.healthcheck.status). to eq(200)
    end
  end

  describe 'error handling' do
    it 'parses returned JSON errors', vcr: { cassette_name: 'client_json_error' } do
      expect {
        subject.get('/prisons/ff6eb0ca-da69-4495-ac9d-b383e01371eb', idempotent: false)
      }.to raise_error(PrisonVisits::APIError, 'Unexpected status 401 calling GET /api/prisons/ff6eb0ca-da69-4495-ac9d-b383e01371eb: {"message"=>"get off my back"}')
    end

    it 'handles non-JSON error gracefully' do
      stub_request(:get, /flubble/).
        to_return(body: "Server error", status: 500)

      expect {
        subject.get('/flubble')
      }.to raise_error(PrisonVisits::APIError, 'Unexpected status 500 calling GET /api/flubble: (invalid-JSON) Server error')
    end

    it 'returns an APIError if there is another (non-response) error' do
      stub_request(:get, /flubble/).to_raise(Excon::Errors::Timeout)

      expect {
        subject.get('/flubble')
      }.to raise_error(PrisonVisits::APIError, 'Exception Excon::Error::Timeout calling GET /api/flubble: Exception from WebMock')
    end

    it 'retries idempotent methods by default', vcr: { cassette_name: 'client_json_error_idempotent' } do
      expect {
        subject.get('/prisons/ff6eb0ca-da69-4495-ac9d-b383e01371eb')
      }.to raise_error(PrisonVisits::APIError, 'Unexpected status 401 calling GET /api/prisons/ff6eb0ca-da69-4495-ac9d-b383e01371eb: {"message"=>"get off my back"}')

      expect(a_request(:get, /\w/)).to have_been_made.times(3)
    end

    it 'encodes the URL', vcr: { cassette_name: 'encode_url' } do
      expect {
        subject.get('/visits/much ado about nothing')
      }.to raise_error(PrisonVisits::APINotFound, 'GET /api/visits/much+ado+about+nothing')
    end

    context 'Resource Not Found', vcr: { cassette_name: 'client_not_found' } do
      it "raises a PrisonVisits::APINotFound" do
        expect {
          subject.get('/prisons/missing')
        }.to raise_error(PrisonVisits::APINotFound, 'GET /api/prisons/missing')
      end
    end
  end
end
