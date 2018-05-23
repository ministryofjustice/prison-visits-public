require 'rails_helper'

RSpec.describe HighVoltage::PagesController do
  render_views

  %w[ cookies terms_and_conditions privacy_policy unsubscribe ].each do |page_name|
    it "renders #{page_name} successfully" do
      get :show, params: { id: page_name }
      expect(response).to have_http_status(:ok)
    end
  end
end
