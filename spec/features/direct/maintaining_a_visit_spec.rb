require 'rails_helper'
require 'notifications/client'

RSpec.feature 'Booking a visit direct to nomis and to staff model', :js do
  include FeaturesHelper

  # Whitespace on email to test stripping
  let(:visitor_email) { ' ado@test.example.com ' }
  let(:available_dates) {
    %w[2017-03-14
       2017-03-15
       2017-03-16
       2017-03-17
       2017-03-18
       2017-03-19
       2017-03-20
       2017-03-21
       2017-03-22
       2017-03-23
       2017-03-24
       2017-03-25
       2017-03-26
       2017-03-27
       2017-03-28
       2017-03-29
       2017-03-30
       2017-03-31]
  }

  # stub nomis oauth

  let(:access_token) do
    'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImRwcy1jbGllbnQta2V5In0.eyJzdWIiOiJ0' \
      'ZXN0IiwiZ3JhbnRfdHlwZSI6ImNsaWVudF9jcmVkZW50aWFscyIsInNjb3BlIjpbInJlYWQiLCJ3cml0' \
      'ZSJdLCJhdXRoX3NvdXJjZSI6Im5vbmUiLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjkwOTAvYXV0aC9p' \
      'c3N1ZXIiLCJleHAiOjE2Nzg0NjY3MTEsImp0aSI6IkRIbnY3ZElCSFdjdmh6akdlTFotZFlGSndGMCIs' \
      'ImNsaWVudF9pZCI6InRlc3QifQ.QLYRxudeQeh_54fJmMNevmHrt2d6hci6qqbqskPt41hvFWCLOrA4T' \
      'LJSkRsu-u3l1grZKpWJWKUlI0v51BnjnzkJ8oJBUQ738qILpN_lZixxxP1QB2sqL-tO2NgXW3H2-HPvJ' \
      'muUWABr5WBbzEbCvy9xMQhlMGN3BAi-EbbOmAjzP53194ggcojHz2tlAfav6Z8qSc1BKeSrMRVq6cA42' \
      'xLER61URCSAYfjRa_wTlFALi-K7CKdsD2T8zsO2H8kBxDx5nJN_5beMPCFkKLN66NAEtiAfEgHZE9ri4' \
      '7gWVC1gPrm6-S6CoIGu54KNQ6hF8rsntFeFvPr1ff8WrRgOtg'
  end

  let(:nomis_oauth_host) { 'http://localhost:9090' }
  let(:nomis_oauth_client_id) { 'test' }
  let(:nomis_oauth_client_secret) { '6+9tp<TO4b0!s)>>hSA.Kq7Rjtab.6V9P-lW*TZIW:2nj8>u&2F&>snY5G9v' }
  let(:slot) {
    ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
  }

  before do
    travel_to Date.parse('2017-03-08')
    Rails.configuration.use_staff_api_old = Rails.configuration.use_staff_api
    Rails.configuration.use_staff_api = false
    Rails.configuration.public_prisons_with_slot_availability = []
    Rails.configuration.vsip_host = nil
    create(:staff_prison, id: 'bf29bf0f-a046-43d1-911b-59ac58730eff', name: 'Leicester', estate: create(:staff_estate))
    create(:staff_prison, id: 'bf29bf0f-a046-43d1-911b-59ac58730efx', name: 'Usk')

    # stub nomis oauth

    Nomis::Oauth::TokenService.host = nomis_oauth_host
    Nomis::Oauth::Client.nomis_oauth_client_id = nomis_oauth_client_id
    Nomis::Oauth::Client.nomis_oauth_client_secret = nomis_oauth_client_secret

    stub_request(:post, "#{nomis_oauth_host}/auth/oauth/token?grant_type=client_credentials").
      to_return(
        body: {
          access_token:,
          token_type: 'bearer',
          expires_in: 3599,
          scope: 'read write',
          sub: 'test',
          auth_source: 'none',
          jti: 'DHnv7dIBHWcvhzjGeLZ-dYFJwF0',
          iss: 'http://localhost:9090/auth/issuer'
        }.to_json
      )

    # stub nomis enpoints

    stub_request(:get, "#{AuthHelper::API_PREFIX}/lookup/active_offender?date_of_birth=1960-06-01&noms_id=A1410AE").
      to_return(body: { found: true, offender: { id: 'A1410AE' } }.to_json)

    # stub slots

    stub_request(:get, /.*available_dates.*/).to_return(body: { dates: available_dates }.to_json)

    # Notifier email

    allow(GovNotifyEmailer).to receive(:new).and_return(GovNotifyEmailerMock.new)
  end

  after do
    travel_back

    # stub nomis oauth
    Nomis::Oauth::TokenService.host = Rails.configuration.nomis_oauth_host
    Nomis::Oauth::Client.nomis_oauth_client_id = Rails.configuration.nomis_oauth_client_id
    Nomis::Oauth::Client.nomis_oauth_client_secret = Rails.configuration.nomis_oauth_client_secret

    Rails.configuration.use_staff_api = Rails.configuration.use_staff_api_old
  end

  scenario 'viewing and withdrawing a visit request' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    click_link 'No more to add'

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )

    click_button 'Continue'

    expect(page).to have_text('Check your visit details')

    click_button 'Send visit request'

    visit visit_path(id: Staff::Visit.last.human_id, locale: 'en')
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

  scenario 'viewing and cancelling a booked visit' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    click_link 'No more to add'

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )

    click_button 'Continue'

    expect(page).to have_text('Check your visit details')

    click_button 'Send visit request'

    visit = Staff::Visit.order(:created_at).last
    visit.processing_state = 'booked'
    visit.slot_granted = ConcreteSlot.new(2035, 11, 5, 13, 30, 14, 45)
    visit.save!

    visit_human_id = visit.human_id
    visit visit_path(id: visit_human_id, locale: 'en')

    find('.summary').click
    check_yes_i_want_to_cancel

    within '.js-SubmitOnce' do
      click_button 'Cancel visit'
    end
    expect(page).to have_text('Your visit is cancelled')
  end

  scenario 'viewing a rejected visit' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    click_link 'No more to add'

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )

    click_button 'Continue'

    expect(page).to have_text('Check your visit details')

    click_button 'Send visit request'

    visit = Staff::Visit.last
    Rejection.new({ reasons: ['slot_unavailable'], visit: }).save!
    visit.reject!
    visit.save!

    visit visit_path(visit.human_id, locale: I18n.locale)

    expect(page).to have_text('Your visit request has been rejected')

    click_link 'new visit'
    expect(page).to have_css('h1', text: 'Who are you visiting?')
  end

  scenario 'viewing a withdrawn visit and trying again' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    click_link 'No more to add'

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )

    click_button 'Continue'

    expect(page).to have_text('Check your visit details')

    click_button 'Send visit request'

    visit visit_path(id: Staff::Visit.last.human_id, locale: 'en')
    expect(page).to have_text('Your visit is not booked yet')

    within '#cancel-visit-section' do
      find('.summary').click
    end

    check_yes_i_want_to_cancel
    within '.js-SubmitOnce' do
      click_button 'Cancel visit'
    end
    click_link 'new visit'
    expect(page).to have_css('h1', text: 'Who are you visiting?')
  end

  scenario 'viewing a cancelled visit and trying again' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    click_link 'No more to add'

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )

    click_button 'Continue'

    expect(page).to have_text('Check your visit details')

    click_button 'Send visit request'

    visit = Staff::Visit.last

    VisitorWithdrawalResponse.new(visit: Staff::Visit.last).withdraw!

    visit visit_path(visit.human_id, locale: I18n.locale)

    expect(page).to have_css('h1', text: 'You cancelled this visit request')

    click_link 'new visit'
    expect(page).to have_css('h1', text: 'Who are you visiting?')
  end
end
