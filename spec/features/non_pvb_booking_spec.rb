require 'rails_helper'

RSpec.feature 'Booking for non-PVB prison', js: true do
  include FeaturesHelper

  scenario 'booking a visit to a private prison', vcr: {
    cassette_name: :private_prison_booking
  } do
    visit booking_requests_path(locale: 'en')
    enter_prisoner_information(prison_name: "Thameside")
    click_button 'Continue'

    expect(page).to have_text('Thameside is privately run and manages its own visitor bookings')
  end

  scenario 'booking a visit at a closed prison', vcr: {
    cassette_name: :closed_prison_booking
  } do
    visit booking_requests_path(locale: 'en')
    enter_prisoner_information(prison_name: "Holloway")
    click_button 'Continue'

    expect(page).to have_text('Holloway prison has shutdown')
  end
end
