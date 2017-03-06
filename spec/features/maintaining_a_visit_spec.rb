require 'rails_helper'

VCR.configure do |config|
  config.default_cassette_options = {
    match_requests_on: %i[ method uri host path body ]
  }
end

RSpec.feature 'Maintaining a visit', js: true do
  include FeaturesHelper

  scenario 'viewing and withdrawing a visit request', vcr: { cassette_name: :maintianing_a_visit_viewing_and_withdrawing } do
    visit visit_path(id: '061c604a-6e3e-4b29-97e4-331e8b0194aa', locale: 'en')
    expect(page).to have_text('Your visit is not booked yet')

    click_link 'cancel this visit'

    check_yes_i_want_to_cancel
    click_button 'Cancel visit'
    expect(page).to have_text('You cancelled this visit request')
  end

  scenario 'viewing and cancelling a booked visit', vcr: { cassette_name: :maintianing_a_visit_viewing_and_cancelling } do
    visit visit_path(id: '0cd7d165-0463-4024-aacf-849475a4c9fc', locale: 'en')
    expect(page).to have_text('Your visit has been confirmed')

    check_yes_i_want_to_cancel
    click_button 'Cancel visit'
    expect(page).to have_text('Your visit is cancelled')
  end

  scenario 'viewing a rejected visit', vcr: { cassette_name: :maintianing_a_visit_viewing_rejected } do
    visit visit_path(id: '147fe485-ea25-437b-9486-05ad6dfa73e4', locale: 'en')
    expect(page).to have_text('Your visit request cannot take place')

    click_link 'new visit'
    expect(current_path).to eq(booking_requests_path(locale: 'en'))
  end

  scenario 'viewing a withdrawn visit and trying again', vcr: { cassette_name: :maintianing_a_visit_viewing_withdrawn } do
    visit visit_path(id: 'f74bc736-cdcf-4e03-92e3-df4897b569ac', locale: 'en')
    expect(page).to have_text('You cancelled this visit request')

    click_link 'new visit'
    expect(current_path).to eq(booking_requests_path(locale: 'en'))
  end

  scenario 'viewing a cancelled visit and trying again', vcr: { cassette_name: :maintianing_a_visit_viewing_cancelled } do
    visit visit_path(id: '93082f13-9194-4a9a-8f0f-cd2aa6add176', locale: 'en')
    expect(page).to have_text('Your visit is cancelled')

    click_link 'new visit'
    expect(current_path).to eq(booking_requests_path(locale: 'en'))
  end
end
