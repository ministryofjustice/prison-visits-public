require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  describe 'show' do
    let(:visit) do
      instance_double(
        Visit,
        id: '123456789',
        processing_state: :rejected,
        messages: [])
    end

    before do
      expect(pvb_api).to receive(:get_visit).with(visit.id).and_return(visit)
    end

    it 'calls the get visit API' do
      get :show, id: visit.id, locale: 'en'
      expect(assigns(:visit)).to eq(visit)
    end

    context "rendering views" do
      render_views

      it 'without errors' do
        expect { get :show, id: visit.id, locale: 'en' }.to_not raise_error
      end
    end
  end
end
