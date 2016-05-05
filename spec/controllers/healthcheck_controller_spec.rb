require 'rails_helper'

RSpec.describe HealthcheckController, type: :controller do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  subject(:index_request) { get :index }

  context 'when everything is OK' do
    before do
      allow_any_instance_of(PrisonVisits::Api).
        to receive(:healthy?).and_return(true)
    end

    it { is_expected.to be_success }

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
      allow_any_instance_of(PrisonVisits::Api).
        to receive(:healthy?).and_return(false)
    end

    it { is_expected.to have_http_status(:bad_gateway) }
  end
end
