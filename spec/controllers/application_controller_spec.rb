require "rails_helper"

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe '#set_locale' do
    context 'with an invalid locale' do
      it 'defaults to en' do
        expect {
          get :index, params: { locale: 'ent' }
        }.to_not raise_error
      end
    end

    context 'with a valid locale' do
      it 'switches the locale' do
        expect {
          get :index, params: { locale: 'cy' }
        }.to change(I18n, :locale).to(:cy)
      end
    end
  end
end
