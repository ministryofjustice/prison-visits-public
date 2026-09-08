require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  let(:parsed_body) {
    JSON.parse(response.body)
  }

  subject(:index_request) { get :index }

  context 'when everything is OK' do
    before do
      nomis_client = instance_double(Nomis::Client, healthcheck: OpenStruct.new(status: 200))
      vsip_client = instance_double(Vsip::Client, healthcheck: OpenStruct.new(status: 200))

      allow(Nomis::Client).to receive(:new).and_return(nomis_client)
      allow(Vsip::Client).to receive(:new).and_return(vsip_client)
    end

    it { is_expected.to be_successful }

    it 'returns the healthcheck data as JSON' do
      index_request

      expect(parsed_body['components']['nomis']['status']).to eq('UP')
      expect(parsed_body['components']['vsip']['status']).to eq('UP')
      expect(parsed_body['status']).to eq('UP')
    end
  end

  context 'when the healthcheck is not OK' do
    before do
      nomis_client = instance_double(Nomis::Client, healthcheck: OpenStruct.new(status: 500))
      vsip_client = instance_double(Vsip::Client, healthcheck: OpenStruct.new(status: 500))

      allow(Nomis::Client).to receive(:new).and_return(nomis_client)
      allow(Vsip::Client).to receive(:new).and_return(vsip_client)
    end

    it 'returns the healthcheck data as JSON' do
      index_request

      expect(parsed_body['components']).to eq({
        'nomis' => { 'detail' => nil, 'status' => 'DOWN' },
        'vsip' => { 'detail' => nil, 'status' => 'DOWN' }
      })
    end
  end
end
