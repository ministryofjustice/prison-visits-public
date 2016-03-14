require 'rails_helper'

RSpec.describe CancellationsController, type: :controller do
  describe 'create' do
    let(:visit_id) { '123456789' }
    let(:pvb_api) { Rails.configuration.pvb_api }

    before do
      allow(pvb_api).to receive(:cancel_visit).and_return(nil)
    end

    context 'when confirm is checked' do
      let(:params) { { id: visit_id, confirmed: '1', locale: 'en' } }

      it 'calls the cancel API' do
        expect(pvb_api).to receive(:cancel_visit).with(visit_id)
        post :create, params
      end
    end

    context 'when confirm is not checked' do
      let(:params) { { id: visit_id, locale: 'en' } }

      it 'does not call the API' do
        expect(pvb_api).to_not receive(:cancel_visit)
        post :create, params
      end

      it 'redirects to the visit page' do
        post :create, params
        expect(response).to redirect_to(visit_path(visit_id, locale: 'en'))
      end
    end
  end
end
