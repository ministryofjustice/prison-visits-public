require 'rails_helper'

RSpec.describe PrisonVisits::Client do
  subject {
    described_class.new(Rails.configuration.api_host)
  }

  before do
    # Specs use vcr cassettes, no real calls are made
    WebMock.allow_net_connect!

    # Needs to be set for all the requests, otherwise the recorded request's
    # wont match. VCR is set to match the request method, uri, host, path,
    # body, headers
    RequestStore.store[:request_id] = 'unique_id'
  end

  describe 'error handling' do
    it 'parses returned JSON errors', vcr: { cassette_name: 'client_json_error' } do
      expect {
        subject.get('/prisons/missing')
      }.to raise_error(PrisonVisits::APIError, 'Unexpected status 404 when calling /api/prisons/missing: {"message"=>"Not found"}')
    end

    it 'handles non-JSON error gracefully' do
      stub_request(:get, /flubble/).
        to_return(body: "Server error", status: 500)

      expect {
        subject.get('/flubble')
      }.to raise_error(PrisonVisits::APIError, 'Unexpected status 500 when calling /api/flubble: (invalid-JSON) Server error')
    end

    it 'returns an APIError if there is another (non-response) error' do
      stub_request(:get, /flubble/).to_raise(Excon::Errors::Timeout, 'oops')

      expect {
        subject.get('/flubble')
      }.to raise_error(PrisonVisits::APIError, 'Unexpected exception Excon::Errors::Timeout calling /api/flubble: Exception from WebMock')
    end
  end
end
