require 'rails_helper'
require './app/services/nomis/client'

RSpec.describe Nomis::Api do
  subject { described_class.instance }

  # Ensure that we have a new instance to prevent other specs interfering
  around do |ex|
    Singleton.__init__(described_class)
    ex.run
    Singleton.__init__(described_class)
  end

  it 'is implicitly enabled if the api host is configured' do
    expect(Rails.configuration).to receive(:prison_api_host).and_return(nil)
    expect(described_class.enabled?).to be false

    expect(Rails.configuration).to receive(:prison_api_host).and_return('http://example.com/')
    expect(described_class.enabled?).to be true
  end

  it 'fails if code attempts to use the client when disabled' do
    expect(described_class).to receive(:enabled?).and_return(false)
    expect {
      described_class.instance
    }.to raise_error(Nomis::Error::Disabled, 'Nomis API is disabled')
  end

  describe 'lookup_active_prisoner' do
    before do
      stub_request(:post, "https://sign-in-dev.hmpps.service.justice.gov.uk/auth/oauth/token?grant_type=client_credentials").
        to_return(
          body: {
            access_token: :access_token,
            token_type: 'bearer',
            expires_in: 3599,
            scope: 'read write',
            sub: 'test',
            auth_source: 'none',
            jti: 'DHnv7dIBHWcvhzjGeLZ-dYFJwF0',
            iss: 'http://localhost:9090/auth/issuer'
          }.to_json
        )
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/lookup/active_offender?date_of_birth=1966-11-22&noms_id=G7244GR").
        to_return(
          body: {
            "found" => true, "offender": { "id" => 1_502_035 }
          }.to_json
        )
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/lookup/active_offender?date_of_birth=1966-11-22&noms_id=Z9999ZZ").
        to_return(
          body: {
            "found" => false, "offender": { "id" => 1_502_035 }
          }.to_json
        )
    end

    let(:params) {
      {
        noms_id: 'G7244GR',
        date_of_birth: Date.parse('1966-11-22')
      }
    }

    let(:prisoner) { subject.lookup_active_prisoner(**params) }

    it 'returns and prisoner if the data matches' do
      expect(prisoner).to be_kind_of(Nomis::Prisoner)
      expect(prisoner.nomis_offender_id).to eq(1_502_035)
      expect(prisoner.noms_id).to eq('G7244GR')
    end

    it 'returns NullPrisoner if the data does not match' do
      params[:noms_id] = 'Z9999ZZ'
      expect(prisoner).to be_instance_of(Nomis::NullPrisoner)
    end

    it 'returns NullPrisoner if an ApiError is raised', :expect_exception do
      allow_any_instance_of(Nomis::Client).to receive(:get).and_raise(Nomis::APIError)
      expect(prisoner).to be_instance_of(Nomis::NullPrisoner)
      expect(prisoner).not_to be_api_call_successful
    end

    it 'logs the lookup result, api lookup time' do
      prisoner
      expect(PVB::Instrumentation.custom_log_items[:valid_prisoner_lookup]).to be true
    end

    describe 'with no matching prisoner' do
      before do
        params[:noms_id] = 'Z9999ZZ'
      end

      it 'returns nil if the data does not match' do
        expect(prisoner).to be_instance_of(Nomis::NullPrisoner)
      end

      it 'logs the prisoner was unsucessful' do
        prisoner
        expect(PVB::Instrumentation.custom_log_items[:valid_prisoner_lookup]).to be false
      end
    end
  end

  describe '#lookup_prisoner_details' do
    before do
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offender/active_offender?date_of_birth=1966-11-22&noms_id=Z9999ZZ").
        to_return(
          body: {
            "found" => false, "offender": { "id" => 1_502_035 }
          }.to_json
        )
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offender/active_offender?date_of_birth=1966-11-22&noms_id=Z9999ZZ").
        to_return(
          body: {
            "found" => false, "offender": { "id" => 1_502_035 }
          }.to_json
        )
      stub_request(:post, "https://sign-in-dev.hmpps.service.justice.gov.uk/auth/oauth/token?grant_type=client_credentials").
        to_return(
          body: {
            access_token: :access_token,
            token_type: 'bearer',
            expires_in: 3599,
            scope: 'read write',
            sub: 'test',
            auth_source: 'none',
            jti: 'DHnv7dIBHWcvhzjGeLZ-dYFJwF0',
            iss: 'http://localhost:9090/auth/issuer'
          }.to_json
        )
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offenders/G7244GR").
        to_return(
          body: {
            "given_name" => "UDFSANAYE",
            "surname" => "KURTEEN",
            "date_of_birth" => "1966-11-22",
            "aliases" => [],
            "gender" => { "code" => "M", "desc" => "Male" },
            "nationalities" => "British",
            "religion" => { "code" => "RC", "desc" => "Roman Catholic" },
            "ethnicity" => { "code" => "W1", "desc" => "White: Eng./Welsh/Scot./N.Irish/British" },
            "csra" => { "code" => "HI", "desc" => "High" },
            "convicted" => true,
            "pnc_number" => "84/36220X",
            "cro_number" => "36220/84R",
            "imprisonment_status" => { "code" => "SENT03", "desc" => "Adult Imprisonment Without Option CJA03" },
            "iep_level" => { "code" => "ENH", "desc" => "Enhanced" },
            "security_category" => { "code" => "C", "desc" => "Cat C" }
          }.to_json
        )
    end

    let(:prisoner_details) { described_class.instance.lookup_prisoner_details(noms_id:) }

    context 'when found' do
      let(:noms_id) { 'G7244GR' }

      it 'serialises the response into a prisoner' do
        expect(prisoner_details).
          to have_attributes(
            given_name: "UDFSANAYE",
            surname: "KURTEEN",
            date_of_birth: Date.parse('1966-11-22'),
            aliases: [],
            gender: { 'code' => 'M', 'desc' => 'Male' },
            convicted: true,
            imprisonment_status: { "code" => "SENT03", "desc" => "Adult Imprisonment Without Option CJA03" },
            iep_level: { "code" => "ENH", "desc" => "Enhanced" }
          )
      end

      it 'instruments the request' do
        prisoner_details
        expect(PVB::Instrumentation.custom_log_items[:valid_prisoner_details_lookup]).to be true
      end
    end

    context 'when an unknown prisoner', :expect_exception do
      let(:noms_id) { 'G999999' }

      it { expect { prisoner_details }.to raise_error(Nomis::APIError) }
    end

    context 'when given an invalid nomis id', :expect_exception do
      let(:noms_id) { 'RUBBISH' }

      it { expect { prisoner_details }.to raise_error(Nomis::APIError) }
    end
  end

  describe '#lookup_prisoner_location' do
    let(:establishment) { subject.lookup_prisoner_location(noms_id:) }

    before do
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offenders/G7244GR/location").
        to_return(
          body: {
            "establishment" => { "code" => "LEI", "desc" => "LEEDS (HMP)" },
            "housing_location" => { "description" => "LEI-F-3-005",
                                    "levels" => [{ "type" => "Wing", "value" => "F" },
                                                 { "type" => "Landing", "value" => "3" },
                                                 { "type" => "Cell", "value" => "005" }] }
          }.to_json
        )
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offenders/BOGUS/location").
        and_raise(Nomis::APIError)
    end

    context 'when found' do
      let(:noms_id) { 'G7244GR' }

      it 'returns a Location' do
        expect(establishment).to be_valid
        expect(establishment.code).to eq 'LEI'
      end

      it 'has the internal location' do
        expect(establishment).to have_attributes(housing_location: instance_of(Nomis::HousingLocation))
        expect(establishment.housing_location.description).to eq 'LEI-F-3-005'
      end
    end

    context 'with an unknown offender', :expect_exception do
      let(:noms_id) { 'G999999' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
    end

    context 'with an invalid nomis_id', :expect_exception do
      let(:noms_id) { 'BOGUS' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
    end
  end

  describe 'prisoner_visiting_availability' do
    before do
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offenders/1502035/visits/available_dates?end_date=2020-10-25&start_date=2020-10-15").
        to_return(
          body: {
            "dates" => ["2020-10-15",
                        "2020-10-16",
                        "2020-10-17",
                        "2020-10-18",
                        "2020-10-19",
                        "2020-10-20",
                        "2020-10-21",
                        "2020-10-22",
                        "2020-10-23",
                        "2020-10-24",
                        "2020-10-25"]
          }.to_json
        )
      stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offenders/1502036/visits/available_dates?end_date=2020-10-25&start_date=2020-10-15").
        to_return(
          body: {
            "dates" => []
          }.to_json
        )
    end

    let(:params) {
      {
        offender_id: 1_502_035,
        start_date: '2020-10-15',
        end_date: '2020-10-25'
      }
    }

    context 'when the prisoner has availability' do
      subject { super().prisoner_visiting_availability(**params) }

      it 'returns availability info containing a list of available dates' do
        expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
        expect(subject.dates.first).to eq(Date.parse('2020-10-15'))
      end

      it 'logs the number of available dates' do
        expect(subject.dates.count).to eq(PVB::Instrumentation.custom_log_items[:prisoner_visiting_availability])
      end
    end

    context 'when the prisoner has no availability' do
      # This spec has to have a hard coded date as an offender MUST be unavailable on a specific date in order for this to
      # pass.  Unfortunately we are unable to use 'travel_to' and go to the past as the JWT token skew is too large.  If this
      # test needs updating a new date will need to be added and updated as part of the VCR being recorded
      let(:params) {
        {
          offender_id: 1_502_036,
          start_date: '2020-10-15',
          end_date: '2020-10-25'
        }
      }

      subject { super().prisoner_visiting_availability(**params) }

      it 'returns empty list of available dates if there is no availability' do
        expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
        expect(subject.dates).to be_empty
      end
    end
  end

  describe 'prisoner_visiting_detailed_availability' do
    before do
      stub_request(:get, 'https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offenders/1502035/visits/unavailability?dates=2020-10-15,2020-10-16,2020-10-17').
        to_return(
          body: {
            "2020-10-15" => { "external_movement" => false, "existing_visits" => [], "out_of_vo" => false, "banned" => false },
            "2020-10-16" => { "external_movement" => false, "existing_visits" => [], "out_of_vo" => false, "banned" => false },
            "2020-10-17" => { "external_movement" => false, "existing_visits" => [], "out_of_vo" => false, "banned" => false }

          }.to_json
        )
    end

    let(:slot1) { ConcreteSlot.new(2020, 10, 15, 10, 0, 11, 0) }
    let(:slot2) { ConcreteSlot.new(2020, 10, 16, 10, 0, 11, 0) }
    let(:slot3) { ConcreteSlot.new(2020, 10, 17, 10, 0, 11, 0) }
    let(:params) do
      {
        offender_id: 1_502_035,
        slots: [slot1, slot2, slot3]
      }
    end

    subject { super().prisoner_visiting_detailed_availability(**params) }

    it 'returns availability info containing a list of available dates' do
      expect(subject).to be_kind_of(Nomis::PrisonerDetailedAvailability)
      expect(subject.dates.map(&:date)).
        to contain_exactly(slot1.to_date, slot2.to_date, slot3.to_date)
    end

    it 'logs the number of available slots' do
      subject
      expect(PVB::Instrumentation.custom_log_items[:prisoner_visiting_availability]).to eq(3)
    end
  end

  describe 'fetch_bookable_slots' do
    # There have been issues with the visit slots for Leeds in T3 and therefore we have switched to use The Verne
    # for this spec
    let(:params) {
      {
        prison: instance_double(Staff::Prison, nomis_id: 'VEI'),
        start_date: '2020-10-14',
        end_date: '2020-10-24'
      }
    }

    before do
      stub_request(:get, 'https://prison-api-dev.prison.service.justice.gov.uk/api/v1/prison/VEI/slots?end_date=2020-10-24&start_date=2020-10-14').
        to_return(
          body: {
            "slots" => [{ "time" => "2020-10-14T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-15T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-16T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-17T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 100,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-18T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-19T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-20T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-21T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-22T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-23T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 99,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 },
                        { "time" => "2020-10-24T14:00/16:00",
                          "capacity" => 100,
                          "max_groups" => 50,
                          "max_adults" => 100,
                          "groups_booked" => 0,
                          "visitors_booked" => 0,
                          "adults_booked" => 0 }]
          }.to_json
        )
    end

    subject { super().fetch_bookable_slots(**params) }

    it 'returns an array of slots' do
      expect(subject.first.time.iso8601).to eq("2020-10-14T14:00/16:00")
    end

    it 'logs the number of available slots' do
      expect(subject.count).to eq(PVB::Instrumentation.custom_log_items[:slot_visiting_availability])
    end
  end

  describe 'fetch_contact_list' do
    before do
      stub_request(:get, 'https://prison-api-dev.prison.service.justice.gov.uk/api/v1/offenders/1502035/visits/contact_list').
        to_return(
          body: {
            "contacts": [{ "id": 2_996_406,
                           "given_name": "AELAREET",
                           "surname": "ANTOINETTE",
                           "date_of_birth": "1990-09-22",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "SON", "desc": "Son" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 3_191_193,
                           "given_name": "DABUOTHDAVID",
                           "surname": "AUGEVIEVE",
                           "date_of_birth": "1986-03-09",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "NIE", "desc": "Niece" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 2_996_409,
                           "given_name": "IRILISA",
                           "surname": "BRADERTO",
                           "date_of_birth": "1995-01-19",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "SON", "desc": "Son" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 3_191_231,
                           "given_name": "EDFMINNO",
                           "surname": "CAITLYLE",
                           "date_of_birth": "1954-03-11",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "UN", "desc": "Uncle" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 3_323_356,
                           "given_name": "YFHINNAIN",
                           "surname": "CARTYSSUS",
                           "date_of_birth": "1994-08-09",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "FRI", "desc": "Friend" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 252_262, "given_name": "''LSIEDE", "surname": "DAIJALIE", "relationship_type": { "code": "SOL", "desc": "Solicitor" }, "contact_type": { "code": "O", "desc": "Official" }, "approved_visitor": true, "active": false, "restrictions": [] },
                         { "id": 74_560,
                           "given_name": "IJAGORENA",
                           "surname": "DREW",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "PROB",
                                                  "desc": "Probation
        Officer" },
                           "contact_type": { "code": "O", "desc": "Official" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 2_459_488,
                           "given_name": "YSJANHKUMAR",
                           "surname": "EDITHA",
                           "date_of_birth": "1961-06-06",
                           "relationship_type": { "code": "AUNT", "desc": "Aunt" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 1_834_701,
                           "given_name": "UNSALNDER",
                           "surname": "ERNAN",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "UN", "desc": "Uncle" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 3_102_890,
                           "given_name": "IHEWLYN",
                           "surname": "ESSINE",
                           "date_of_birth": "1949-10-13",
                           "relationship_type": { "code": "AUNT", "desc": "Aunt" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 2_459_489,
                           "given_name": "YSJANHKUMAR",
                           "surname": "JARRANIE",
                           "date_of_birth": "1964-09-11",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "FRI", "desc": "Friend" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 2_996_430,
                           "given_name": "IRILISA",
                           "surname": "JAYMELLA",
                           "date_of_birth": "1955-07-06",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "FRI", "desc": "Friend" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 3_191_201,
                           "given_name": "DABUOTHDAVID",
                           "surname": "KAYLARY",
                           "date_of_birth": "1989-05-03",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "NIE", "desc": "Niece" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 1_375_628,
                           "given_name": "UALICNAIN",
                           "surname": "KIMBUR",
                           "date_of_birth": "1967-11-06",
                           "relationship_type": { "code": "SIS", "desc": "Sister" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 1_203_649,
                           "given_name": "URKSIEARIE",
                           "surname": "LETWIN",
                           "date_of_birth": "1948-10-09",
                           "relationship_type": { "code": "FA", "desc": "Father" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 3_191_221,
                           "given_name": "OZGNATON",
                           "surname": "LUNIVER",
                           "date_of_birth": "1964-06-07",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "COU", "desc": "Cousin" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 75_757, "given_name": "IJAGORENA", "surname": "MALLERY", "gender": { "code": "M", "desc": "Male" }, "relationship_type": { "code": "SOL", "desc": "Solicitor" }, "contact_type": { "code": "O", "desc": "Official" }, "approved_visitor": true, "active": false, "restrictions": [] },
                         { "id": 75_757,
                           "given_name": "IJAGORENA",
                           "surname": "MALLERY",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "SIS", "desc": "Sister" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 2_996_433,
                           "given_name": "IRILISA",
                           "surname": "MOLLIS",
                           "date_of_birth": "1955-11-26",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "FRI", "desc": "Friend" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 2_931_624,
                           "given_name": "EETNIFUI",
                           "surname": "REMICK",
                           "date_of_birth": "1947-09-25",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "AUNT", "desc": "Aunt" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 2_931_619,
                           "given_name": "EETNIFUI",
                           "surname": "SALLICA",
                           "date_of_birth": "1967-11-28",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "SIS", "desc": "Sister" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 3_101_980,
                           "given_name": "ETSINLOUISE",
                           "surname": "SANDINEE",
                           "date_of_birth": "1949-10-02",
                           "relationship_type": { "code": "FRI", "desc": "Friend" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 1_206_106,
                           "given_name": "ESNTERNS",
                           "surname": "SAVIS",
                           "date_of_birth": "1948-08-29",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "FA", "desc": "Father" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": true,
                           "restrictions": [] },
                         { "id": 2_054_299,
                           "given_name": "OKBKEIGH",
                           "surname": "SHAMIR",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "OTH",
                                                  "desc": "Other
        - Official" },
                           "contact_type": { "code": "O", "desc": "Official" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 2_447_707,
                           "given_name": "EHSREECHI",
                           "surname": "SHEMEMAN",
                           "date_of_birth": "1971-10-07",
                           "gender": { "code": "M", "desc": "Male" },
                           "relationship_type": { "code": "FRI", "desc": "Friend" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 3_191_214,
                           "given_name": "YDFDANDER",
                           "surname": "TONINALD",
                           "date_of_birth": "1965-05-02",
                           "gender": { "code": "F", "desc": "Female" },
                           "relationship_type": { "code": "COU", "desc": "Cousin" },
                           "contact_type": { "code": "S",
                                             "desc": "Social/
        Family" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] },
                         { "id": 39_896,
                           "given_name": "AAANIO",
                           "surname": "YVYGSEE",
                           "relationship_type": { "code": "PROB",
                                                  "desc": "Probation
        Officer" },
                           "contact_type": { "code": "O", "desc": "Official" },
                           "approved_visitor": true,
                           "active": false,
                           "restrictions": [] }]
          }.to_json
        )
    end

    let(:params) do
      {
        offender_id: 1_502_035
      }
    end

    let(:first_contact) do
      Nomis::Contact.new(
        id: 2_996_406,
        given_name: 'AELAREET',
        surname: 'ANTOINETTE',
        date_of_birth: '1990-09-22',
        gender: { code: "M", desc: "Male" },
        active: true,
        approved_visitor: true,
        relationship_type: { code: "SON", desc: "Son" },
        contact_type: {
          code: "S",
          desc: "Social/ Family"
        },
        restrictions: []
      )
    end

    subject { super().fetch_contact_list(**params) }

    it 'returns an array of contacts' do
      expect(subject.count).to eq(27)
    end

    it 'parses the contacts' do
      expect(subject.map(&:id)).to include(first_contact.id)
    end
  end
end
