require 'rails_helper'

RSpec.feature 'Cookie banner', :js do
  include FeaturesHelper

  cookie_banner_text_1 = "This service uses cookies which are essential for the site to work. We also use non-essential cookies to help us improve your experience."
  cookie_banner_text_2 = "Do you accept these non-essential cookies?"
  cookie_banner_text_3 = "Accept cookies Reject cookies View more information"

  scenario 'first navigating to cookies page', vcr: {
    cassette_name: :private_prison_booking
  } do
    visit booking_requests_path(locale: 'en')
    expect(page).to have_text(cookie_banner_text_1)
    expect(page).to have_text(cookie_banner_text_2)
    expect(page).to have_text(cookie_banner_text_3)
  end

  scenario 'accpeting cookies', vcr: {
    cassette_name: :private_prison_booking
  } do
    visit booking_requests_path(locale: 'en')
    click_button 'Accept cookies'
    expect(page).to_not have_text(cookie_banner_text_1)
    expect(page).to_not have_text(cookie_banner_text_2)
    expect(page).to_not have_text(cookie_banner_text_3)
  end

  scenario 'rejecting cookies', vcr: {
    cassette_name: :private_prison_booking
  } do
    visit booking_requests_path(locale: 'en')
    click_button 'Reject cookies'
    expect(page).to_not have_text(cookie_banner_text_1)
    expect(page).to_not have_text(cookie_banner_text_2)
    expect(page).to_not have_text(cookie_banner_text_3)
  end

  scenario 'accepting cookies from cookies page', vcr: {
    cassette_name: :private_prison_booking
  } do
    visit booking_requests_path(locale: 'en')
    click_on 'View more information'
    expect(page).to have_text(cookie_banner_text_1)
    expect(page).to have_text(cookie_banner_text_2)
    expect(page).to have_text(cookie_banner_text_3)
    choose(option: 'yes', visible: false)
    click_button 'Save changes'
    expect(page).to_not have_text(cookie_banner_text_1)
    expect(page).to_not have_text(cookie_banner_text_2)
    expect(page).to_not have_text(cookie_banner_text_3)
  end

  scenario 'rejecting cookies from cookies page', vcr: {
    cassette_name: :private_prison_booking
  } do
    visit booking_requests_path(locale: 'en')
    click_on 'View more information'
    expect(page).to have_text(cookie_banner_text_1)
    expect(page).to have_text(cookie_banner_text_2)
    expect(page).to have_text(cookie_banner_text_3)
    choose(option: 'yes', visible: false)
    click_button 'Save changes'
    expect(page).to_not have_text(cookie_banner_text_1)
    expect(page).to_not have_text(cookie_banner_text_2)
    expect(page).to_not have_text(cookie_banner_text_3)
  end
end
