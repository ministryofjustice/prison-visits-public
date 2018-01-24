require 'rails_helper'

RSpec.describe HealthcheckController, type: :controller do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  subject(:index_request) { get :index }

  context 'when everything is OK' do
    before do
      allow_any_instance_of(PrisonVisits::Client).
        to receive(:healthcheck).
        and_return(double(status: 200))
    end

    it { is_expected.to be_successful }

    it 'returns the healthcheck data as JSON' do
      index_request

      expect(parsed_body).to eq(
        'api' => {
          'description' => "PVB API healthcheck",
          'ok' => true
        },
        'ok' => true
      )
    end
  end

  context 'when the healthcheck is not OK' do
    before do
      allow_any_instance_of(PrisonVisits::Client).
        to receive(:healthcheck).
        and_return(double(status: 502))
    end

    it { is_expected.to have_http_status(:bad_gateway) }
  end
end
