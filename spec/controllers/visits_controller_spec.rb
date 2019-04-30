require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  describe 'show' do
    let(:visit) do
      instance_double(Visit,
                      id: '123456789',
                      human_id: 'ABCEFGHI',
                      processing_state: :rejected)
    end

    context "with no errors" do
      render_views

      before do
        expect(pvb_api).to receive(:get_visit).with(visit.human_id).and_return(visit)
        expect(visit).to receive(:prison_name)
      end

      it 'calls the get visit API' do
        get :show, params: { id: visit.human_id, locale: 'en' }
        expect(assigns(:visit)).to eq(visit)
      end

      it 'rendering views' do
        expect { get :show, params: { id: visit.human_id, locale: 'en' } }.to_not raise_error
      end
    end

    context 'with a non existent visit' do
      let(:visit_id) { 'i_dont_exsit' }

      before do
        expect(pvb_api).to receive(:get_visit).with(visit_id).and_raise(PrisonVisits::APINotFound)
      end

      it 'renders a 404' do
        get :show, params: { id: visit_id, locale: 'en' }
        expect(response).to render_template('404')
        expect(response).to be_not_found
      end
    end
  end
end
