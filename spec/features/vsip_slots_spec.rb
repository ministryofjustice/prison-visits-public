require 'rails_helper'

RSpec.feature 'Booking a visit', js: true do
  include FeaturesHelper

  # Whitespace on email to test stripping
  let(:visitor_email) { ' ado@test.example.com ' }

  before do
    travel_to Date.parse('2017-03-08')
  end

  after do
    travel_back
  end

  scenario 'no slots', vcr: {
    cassette_name: :vsip_without_slots,
    allow_playback_repeats: true
  } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information(
      first_name: 'Aiemonda',
      last_name: 'Gracasina',
      date_of_birth: Date.new(1985, 10, 3),
      number: 'G6587UU',
      prison_name: 'Hewell'
    )
    click_button 'Continue'

    expect(page).to have_text('You can\'t book a visit right now')
    expect(page).to have_text('This is because the prison has no available visit slots for the next 28 days.')
    expect(page).to have_text('Our calendars are updated daily, so please try again later.')
  end

  scenario 'one slot', vcr: {
    cassette_name: :vsip_one_slots,
    allow_playback_repeats: true
  } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information(
      first_name: 'Aiemonda',
      last_name: 'Gracasina',
      date_of_birth: Date.new(1985, 10, 3),
      number: 'G6587UU',
      prison_name: 'Hewell'
    )
    click_button 'Continue'

    (1..12).each do |day| expect(page.find_by_id("day#{day}")[:class]).to include("disabled") end
    expect(page.find_by_id("day13")[:class]).to include("available")
    (14..31).each { |day| expect(page.find_by_id("day#{day}")[:class]).to include("disabled") }
  end

  scenario 'multiple slot', vcr: {
    cassette_name: :vsip_multiple_slots,
    allow_playback_repeats: true
  } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information(
      first_name: 'Aiemonda',
      last_name: 'Gracasina',
      date_of_birth: Date.new(1985, 10, 3),
      number: 'G6587UU',
      prison_name: 'Hewell'
    )
    click_button 'Continue'

    (1..12).each do |day| expect(page.find_by_id("day#{day}")[:class]).to include("disabled") end
    (13..15).each do |day| expect(page.find_by_id("day#{day}")[:class]).to include("available") end
    (16..31).each { |day| expect(page.find_by_id("day#{day}")[:class]).to include("disabled") }
  end
end
