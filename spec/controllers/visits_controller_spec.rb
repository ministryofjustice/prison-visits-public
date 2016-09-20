require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  describe 'show' do
    let(:visit) { instance_double(Visit, id: '123456789', processing_state: :rejected) }

    context "without errors" do
      render_views

      before do
        expect(pvb_api).to receive(:get_visit).with(visit.id).and_return(visit)
      end

      it 'calls the get visit API' do
        get :show, id: visit.id, locale: 'en'
        expect(assigns(:visit)).to eq(visit)
      end

      it 'rendering views' do
        expect { get :show, id: visit.id, locale: 'en' }.to_not raise_error
      end
    end

    context 'with a non existent visit' do
      let(:visit_id) { 'i_dont_exsit' }
      before do
        expect(pvb_api).to receive(:get_visit).with(visit_id).and_raise(PrisonVisits::APINotFound)
      end

      it 'renders a 404' do
        get :show, id: visit_id, locale: 'en'
        expect(response).to render_template('404')
        expect(response).to be_not_found
      end
    end
  end
end
