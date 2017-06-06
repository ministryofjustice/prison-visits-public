require 'rails_helper'

RSpec.feature 'Submit feedback', js: true do
  include FeaturesHelper

  normalised_body = lambda do |r1, r2|
    puts ">>>>> r1 body: #{r1.body}"
    puts ">>>>> r2 body: #{r2.body}"
    r1.body.gsub(%r{:\d+\/}, ':9999/') == r2.body.gsub(%r{:\d+\/}, ':9999/')
  end

  custom_matchers = [:method, :uri, :host, :path, :valid_uuid, normalised_body]

  scenario 'including prisoner details', vcr: {
    match_requests_on: custom_matchers,
    cassette_name: :submit_feedback
  } do
    text = 'How many times did the Batmobile catch a flat?'
    email_address = 'user@test.example.com'
    prisoner_number = 'A1234BC'
    prisoner_dob_day = 1
    prisoner_dob_month = 1
    prisoner_dob_year = 1999
    prison_name = 'Leeds'

    visit booking_requests_path(locale: 'en')
    click_link 'Contact us'

    fill_in 'Your message', with: text
    fill_in 'Prisoner number', with: prisoner_number
    fill_in 'Day', with: prisoner_dob_day
    fill_in 'Month', with: prisoner_dob_month
    fill_in 'Year', with: prisoner_dob_year
    fill_in 'Prison name', with: prison_name
    fill_in 'Your email address', with: email_address

    click_button 'Send'

    expect(page).to have_text('Thank you for your feedback')
  end

  scenario 'no prisoner details', vcr: {
    match_requests_on: custom_matchers,
    cassette_name: :submit_feedback_no_prisoner_details
  } do
    text = 'How many times did the Batmobile catch a flat?'
    email_address = 'user@test.example.com'

    visit booking_requests_path(locale: 'en')
    click_link 'Contact us'

    fill_in 'Your message', with: text
    fill_in 'Your email address', with: email_address

    click_button 'Send'

    expect(page).to have_text('Thank you for your feedback')
  end
end
