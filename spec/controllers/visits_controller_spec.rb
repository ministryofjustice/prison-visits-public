require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  describe 'show' do
    let(:visit) { instance_double(Visit, id: '123456789') }

    it 'calls the get visit API' do
      expect(pvb_api).to receive(:get_visit).with(visit.id).and_return(visit)
      get :show, id: visit.id, locale: 'en'
      expect(assigns(:visit)).to eq(visit)
    end
  end
end
