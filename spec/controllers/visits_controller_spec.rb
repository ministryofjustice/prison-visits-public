require 'rails_helper'

RSpec.describe VisitsController, type: :controller do
  before do skip 'Status not yet implemented' end

  describe 'show' do
    let(:visit) { create(:visit) }

    it 'assigns the visit to @visit' do
      get :show, id: visit.id, locale: 'en'
      expect(assigns(:visit)).to eq(visit)
    end
  end
end
