require 'rails_helper'

RSpec.feature 'Switching languages' do
  before do skip 'Features specs not yet fixed' end

  include FeaturesHelper

  scenario 'switching between available languages' do
    visit booking_requests_path(locale: 'en')

    expect(page).to have_selector(
      '#proposition-name', text: 'Visit someone in prison'
    )

    click_on('Heävy Mëtal')

    expect(current_path).to eq(booking_requests_path(locale: 'xx'))
    expect(page).to have_selector(
      '#proposition-name', text: 'Visït somëone ïn prïson'
    )

    click_on('English')

    expect(current_path).to eq(booking_requests_path(locale: 'en'))
  end
end
