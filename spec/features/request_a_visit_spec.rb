require 'rails_helper'

VCR.configure do |config|
  config.default_cassette_options = {
    match_requests_on: %i[ method uri host path body ]
  }
end

RSpec.feature 'Booking a visit', js: true do
  include FeaturesHelper

  # Whitespace on email to test stripping
  let(:visitor_email) { ' ado@test.example.com ' }

  scenario 'happy path', vcr: { cassette_name: :request_a_visit_happy_path } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Slot 2
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Slot 3
    select_first_available_date
    select_first_available_slot
    click_button 'Continue'

    enter_visitor_information email_address: visitor_email
    select '1', from: 'How many other visitors?'
    enter_visitor_information index: 1
    click_button 'Continue'

    expect(page).to have_text('Check your request')

    click_button 'Send request'

    expect(page).to have_text('Your request is being processed')
  end

  scenario 'remove middle slot', vcr: { cassette_name: :request_a_visit_remove_middle_slot } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Slot 2
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Slot 3
    select_first_available_date
    select_first_available_slot
    click_button 'Continue'

    enter_visitor_information email_address: visitor_email
    select '1', from: 'How many other visitors?'
    enter_visitor_information index: 1
    click_button 'Continue'

    within('.date-box-2') do
      click_button "Change date and time slot"
    end

    click_link 'Or remove slot'

    expect(page).to have_css('.date-box-1')
    expect(page).to have_css('.date-box-2')
    expect(page).not_to have_css('.date-box-3')
  end

  scenario 'change prison', vcr: { cassette_name: :request_a_visit_change_prison } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Slot 2
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Slot 3
    select_first_available_date
    select_first_available_slot
    click_button 'Continue'

    enter_visitor_information email_address: visitor_email
    select '1', from: 'How many other visitors?'
    enter_visitor_information index: 1
    click_button 'Continue'

    click_button 'Change prisoner details'

    select_prison 'Usk'
    click_button 'Continue'

    # We should be presented with slots page as they should have been cleared
    expect(page).to have_text('When do you want to visit')
  end

  scenario 'skip slots', vcr: { cassette_name: :request_a_visit_skip_slots } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Invoke skip by making no date or slot selection
    click_button 'Add another choice'

    expect(page).to have_text('Your visitor details')
  end

  scenario 'validation errors', vcr: { cassette_name: :request_a_visit_validation_errors } do
    visit booking_requests_path(locale: 'en')
    click_button 'Continue'

    expect(page).to have_text('Prisoner first name is required')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    click_button 'Add another choice'
    expect(page).to have_text('You must choose at least one date and time slot')

    select_first_available_date
    select_first_available_slot
    click_link 'No more to add'

    enter_visitor_information date_of_birth: Date.new(2014, 11, 30)
    click_button 'Continue'

    expect(page).to have_text('The person requesting the visit must be over the age of 18')
  end

  # pending until slot 2 & 3 validation is in place
  xscenario 'slot validation errors', vcr: { cassette_name: :request_a_visit_slot_validation_errors } do
    visit booking_requests_path(locale: 'en')
    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    click_button 'Add another choice'
    expect(page).to have_text('You must choose at least one date and time slot')

    select_first_available_slot
    click_button 'Add another choice'

    # Slot 2
    select_first_available_date
    click_button 'Add another choice'
    expect(page).to have_text('You must choose at least one date and time slot')

    select_first_available_slot
    click_button 'Add another choice'

    # Slot 3
    select_first_available_date
    click_link 'Continue'
    expect(page).to have_text('You must choose at least one date and time slot')

    select_first_available_slot
    click_link 'Continue'

    enter_visitor_information date_of_birth: Date.new(2014, 11, 30)
    click_button 'Continue'

    expect(page).to have_text('The person requesting the visit must be over the age of 18')
  end

  scenario 'review and edit', vcr: { cassette_name: :request_a_visit_review_and_edit } do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    select_first_available_date
    select_first_available_slot
    click_link 'No more to add'

    enter_visitor_information
    click_button 'Continue'

    expect(page).to have_text('Check your request')

    click_button 'Change prisoner details'

    fill_in 'Prisoner last name', with: 'Featherstone-Haugh'
    click_button 'Continue'

    expect(page).to have_text('Check your request')
    expect(page).to have_text('Featherstone-Haugh')

    click_button 'Change visitor details'

    fill_in 'Last name', with: 'Colquhoun'
    click_button 'Continue'

    expect(page).to have_text('Check your request')
    expect(page).to have_text('Colquhoun')

    # Add an alternative slot
    click_button 'Add another choice'

    select_first_available_date
    select_first_available_slot
    click_button 'Save changes'

    expect(page).to have_text('Check your request')
    expect(page).to have_css('.slot-confirmation', count: 2)

    click_button 'Send request'

    expect(page).to have_text('Your request is being processed')
  end
end
