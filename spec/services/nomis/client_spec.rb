require 'rails_helper'

RSpec.describe Nomis::Client do
  subject { described_class.new(api_host) }

  let(:api_host) { Rails.configuration.prison_api_host }

  let(:path) { 'v1/lookup/active_offender' }
  let(:params) {
    {
      noms_id: 'G7244GR',
      date_of_birth: Date.parse('1966-11-22')
    }
  }

  context 'when there is an http status error' do
    let(:error) do
      Excon::Error::HTTPStatus.new('error',
                                   double('request'),
                                   double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError', :expect_exception do
      expect { subject.get(path, params) }.
        to raise_error(Nomis::APIError, 'Unexpected status 422 calling GET /api/v1/lookup/active_offender: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(PVB::ExceptionHandler).to receive(:capture_exception).with(error, fingerprint: %w[nomis excon])

      expect { subject.get(path, params) }.to raise_error(Nomis::APIError)
    end
  end

  context 'when there is a timeout' do
    before do
      WebMock.stub_request(:get, /\w/).to_timeout
    end

    it 'raises an Nomis::TimeoutError if a timeout occurs', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError)
    end
  end

  context 'when there is an unexpected exception' do
    let(:error) do
      Excon::Errors::SocketError.new(StandardError.new('Socket error'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError)
    end
  end

  describe 'with an error' do
    let(:error) do
      Excon::Error::HTTPStatus.new('error',
                                   double('request'),
                                   double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError, 'Unexpected status 422 calling GET /api/v1/lookup/active_offender: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(PVB::ExceptionHandler).to receive(:capture_exception).with(error, fingerprint: %w[nomis excon])

      expect { subject.get(path, params) }.to raise_error(Nomis::APIError)
    end

    it 'increments the api error count', :expect_exception do
      expect {
        subject.get(path, params)
      }.to raise_error(Nomis::APIError)
    end
  end
end
