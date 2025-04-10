require 'rails_helper'

RSpec.feature 'Booking a visit through staff api not using the staff_api', :js do
  include FeaturesHelper

  # Whitespace on email to test stripping
  let(:visitor_email) { ' ado@test.example.com ' }

  let(:nomis_oauth_host) { 'http://localhost:9090' }
  let(:nomis_oauth_client_id) { 'test' }
  let(:nomis_oauth_client_secret) { '6+9tp<TO4b0!s)>>hSA.Kq7Rjtab.6V9P-lW*TZIW:2nj8>u&2F&>snY5G9v' }
  let(:slot) {
    ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
  }

  let(:vsip_available_dates) {
    [{ "sessionDate" => "2024-06-07", "sessionTemplateReference" => "-afe.dcc.10", "sessionTimeSlot" => { "startTime" => "09:00", "endTime" => "10:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-08", "sessionTemplateReference" => "-afe.dcc.11", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-09", "sessionTemplateReference" => "-afe.dcc.12", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-09", "sessionTemplateReference" => "wni.plo.qpn", "sessionTimeSlot" => { "startTime" => "19:00", "endTime" => "21:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-10", "sessionTemplateReference" => "-afe.dcc.14", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-12", "sessionTemplateReference" => "-afe.dcc.0f", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-14", "sessionTemplateReference" => "-afe.dcc.10", "sessionTimeSlot" => { "startTime" => "09:00", "endTime" => "10:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-15", "sessionTemplateReference" => "-afe.dcc.11", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-16", "sessionTemplateReference" => "-afe.dcc.12", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-16", "sessionTemplateReference" => "wni.plo.qpn", "sessionTimeSlot" => { "startTime" => "19:00", "endTime" => "21:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-17", "sessionTemplateReference" => "-afe.dcc.14", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-19", "sessionTemplateReference" => "-afe.dcc.0f", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-21", "sessionTemplateReference" => "-afe.dcc.10", "sessionTimeSlot" => { "startTime" => "09:00", "endTime" => "10:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-23", "sessionTemplateReference" => "-afe.dcc.12", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-23", "sessionTemplateReference" => "wni.plo.qpn", "sessionTimeSlot" => { "startTime" => "19:00", "endTime" => "21:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-24", "sessionTemplateReference" => "-afe.dcc.14", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-26", "sessionTemplateReference" => "-afe.dcc.0f", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-28", "sessionTemplateReference" => "-afe.dcc.10", "sessionTimeSlot" => { "startTime" => "09:00", "endTime" => "10:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-29", "sessionTemplateReference" => "-afe.dcc.11", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-30", "sessionTemplateReference" => "-afe.dcc.12", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-06-30", "sessionTemplateReference" => "wni.plo.qpn", "sessionTimeSlot" => { "startTime" => "19:00", "endTime" => "21:00" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-07-01", "sessionTemplateReference" => "-afe.dcc.14", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }, { "sessionDate" => "2024-07-03", "sessionTemplateReference" => "-afe.dcc.0f", "sessionTimeSlot" => { "startTime" => "13:45", "endTime" => "14:45" }, "sessionRestriction" => "OPEN" }]
  }

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

  before do
    Rails.configuration.use_staff_api_old = Rails.configuration.use_staff_api
    Rails.configuration.use_staff_api = false
    Rails.configuration.vsip_host_old = Rails.configuration.vsip_host
    Rails.configuration.vsip_host = "http://example.com"
    Rails.configuration.public_prisons_with_slot_availability = []
    Rails.configuration.vsip_supported_prisons_retrieved = true

    travel_to Date.parse('2017-03-08')
    create(:staff_prison, id: 'bf29bf0f-a046-43d1-911b-59ac58730eff', name: 'Leicester', estate: create(:staff_estate, vsip_supported: true))
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

    stub_request(:get, /.*visit-sessions.*/).to_return(body: vsip_available_dates.to_json)

    # stub slots

    stub_request(:get, /.*available_dates.*/).to_return(body: { dates: available_dates }.to_json)

    # Notifier email

    allow(GovNotifyEmailer).to receive(:new).and_return(GovNotifyEmailerMock.new)
  end

  after do
    travel_back
    Nomis::Oauth::TokenService.host = Rails.configuration.nomis_oauth_host
    Nomis::Oauth::Client.nomis_oauth_client_id = Rails.configuration.nomis_oauth_client_id
    Nomis::Oauth::Client.nomis_oauth_client_secret = Rails.configuration.nomis_oauth_client_secret
    Rails.configuration.use_staff_api = Rails.configuration.use_staff_api_old
    Rails.configuration.vsip_host = Rails.configuration.vsip_host_old
  end

  scenario 'happy path' do
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

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )

    click_button 'Add another visitor'
    enter_visitor_information index: 1
    click_button 'Continue'

    expect(page).to have_text('Check your visit details')

    click_button 'Send visit request'

    expect(page).to have_text('Visit request sent')
  end

  scenario 'remove middle slot' do
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

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )
    click_button 'Add another visitor'
    enter_visitor_information index: 1
    click_button 'Continue'

    within('.date-box-2') do
      click_button "Change second slot date and time"
    end

    click_link 'Or remove slot'

    expect(page).to have_css('.date-box-1')
    expect(page).to have_css('.date-box-2')
    expect(page).not_to have_css('.date-box-3')
  end

  scenario 'change prison' do
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

    enter_visitor_information(
      email_address: visitor_email,
      email_address_confirmation: visitor_email
    )
    click_button 'Add another visitor'
    enter_visitor_information index: 1
    click_button 'Continue'

    click_button 'Change prisoner details'

    select_prison 'Usk'
    click_button 'Continue'

    # We should be presented with slots page as they should have been cleared
    expect(page).to have_text('When do you want to visit')
  end

  scenario 'skip slots' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    select_first_available_date
    select_first_available_slot
    click_button 'Add another choice'

    # Invoke skip by making no date or slot selection
    click_link 'No more to add'

    expect(page).to have_text('Visitor details')
  end

  scenario 'validation errors' do
    visit booking_requests_path(locale: 'en')
    click_button 'Continue'

    expect(page).to have_text('Enter a first name')

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

  scenario 'slot validation errors' do
    visit booking_requests_path(locale: 'en')
    enter_prisoner_information
    click_button 'Continue'

    # Slot 1
    select_first_available_date
    click_button 'Add another choice'
    expect(page).to have_text('You must choose at least one date and time slot')

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

    enter_visitor_information date_of_birth: Date.new(2014, 11, 30)
    click_button 'Continue'

    expect(page).to have_text('The person requesting the visit must be over the age of 18')
  end

  scenario 'review and edit' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    select_first_available_date
    select_first_available_slot
    click_link 'No more to add'

    enter_visitor_information
    click_button 'Continue'

    expect(page).to have_text('Check your visit details')

    click_button 'Change prisoner details'

    fill_in 'Prisoner last name', with: 'Featherstone-Haugh'
    click_button 'Continue'

    expect(page).to have_text('Check your visit details')
    expect(page).to have_text('Featherstone-Haugh')

    click_button 'Change visitor details'

    fill_in 'Last name', with: 'Colquhoun'
    click_button 'Continue'

    expect(page).to have_text('Check your visit details')
    expect(page).to have_text('Colquhoun')

    # Add an alternative slot
    click_button 'Add another choice'

    select_first_available_date
    select_first_available_slot
    click_button 'Save changes'

    expect(page).to have_text('Check your visit details')
    expect(page).to have_css('.slot-confirmation', count: 2)

    click_button 'Send visit request'

    expect(page).to have_text('Visit request sent')
  end
end
