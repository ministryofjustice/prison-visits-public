require 'rails_helper'

RSpec.feature 'Switching languages' do
  before do skip 'Features specs not yet fixed' end

  include FeaturesHelper

  scenario 'switching between available languages' do
    visit booking_requests_path(locale: 'en')

    expect(page).to have_selector(
      '#proposition-name', text: 'Visit someone in prison'
    )

    click_on('Cymraeg')

    expect(have_current_path).to eq(booking_requests_path(locale: 'cy'))
    expect(page).to have_selector(
      '#proposition-name', text: 'Ymweld â rhywun yn y carchar'
    )

    click_on('English')

    expect(have_current_path).to eq(booking_requests_path(locale: 'en'))

    expect { visit('/fr/request') }.
      to raise_error(ActionController::RoutingError)
  end
end
