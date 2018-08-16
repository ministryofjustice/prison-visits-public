require 'rails_helper'

RSpec.feature 'Maintaining a visit', js: true do
  include FeaturesHelper

  scenario 'viewing and withdrawing a visit request', vcr: {
    cassette_name: :maintianing_a_visit_viewing_and_withdrawing
  } do
    visit visit_path(id: 'FOOBAR', locale: 'en')
    expect(page).to have_text('Your visit is not booked yet')

    within '#cancel-visit-section' do
      find('.summary').click
    end

    check_yes_i_want_to_cancel
    within '.js-SubmitOnce' do
      click_button 'Cancel visit'
    end
    expect(page).to have_text('You cancelled this visit request')
  end

  scenario 'viewing and cancelling a booked visit', vcr: {
    cassette_name: :maintianing_a_visit_viewing_and_cancelling
  } do
    visit visit_path(id: 'FOOBAR', locale: 'en')
    expect(page).to have_text('Your visit has been confirmed')

    within '#cancel-visit-section' do
      find('.summary').click
    end

    check_yes_i_want_to_cancel
    click_button 'Cancel visit'
    expect(page).to have_text('Your visit is cancelled')
  end

  scenario 'viewing a rejected visit', vcr: {
    cassette_name: :maintianing_a_visit_viewing_rejected
  } do
    visit visit_path(id: 'FOOBAR', locale: 'en')
    expect(page).to have_text('Your visit request has been rejected')

    click_link 'new visit'
    expect(page).to have_css('h1', text: 'Who are you visiting?')
  end

  scenario 'viewing a withdrawn visit and trying again', vcr: {
    cassette_name: :maintianing_a_visit_viewing_withdrawn
  } do
    visit visit_path(id: 'FOOBAR', locale: 'en')
    expect(page).to have_text('You cancelled this visit request')

    click_link 'new visit'
    expect(page).to have_css('h1', text: 'Who are you visiting?')
  end

  scenario 'viewing a cancelled visit and trying again', vcr: {
    cassette_name: :maintianing_a_visit_viewing_cancelled
  } do
    visit visit_path(id: 'FOOBAR', locale: 'en')
    expect(page).to have_text('Your visit is cancelled')

    click_link 'new visit'
    expect(page).to have_css('h1', text: 'Who are you visiting?')
  end
end
