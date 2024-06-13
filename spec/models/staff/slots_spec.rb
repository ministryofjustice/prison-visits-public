require "rails_helper"

RSpec.describe Staff::Slots do
  include AuthHelper
  include ConfigurationHelpers

  let(:parsed_body) { JSON.parse(response.body) }
  let(:prisoner) { create(:prisoner) }

  describe 'slots' do
    let(:start_date) { Date.parse('2016-02-09') }
    let(:end_date) { Date.parse('2016-04-15') }

    let(:slots) {
      {
        '2016-02-15T13:30/14:30' => [],
        '2016-03-02T13:30/14:30' => ['prisoner_unavailable'],
        '2016-03-03T13:30/14:30' => ['prisoner_unavailable']
      }
    }
    let(:offender_id) { 1_502_035 }

    before do
      stub_auth_token
    end

    context 'with auto slots enabled' do
      let(:prison) {
        create(:staff_prison,
               booking_window: 28,
               lead_days: 3,
               nomis_concrete_slots: [
                 build(:nomis_concrete_slot, date: Date.new(2016, 2, 15), start_hour: 13, start_minute: 30, end_hour: 14, end_minute: 30),
                 build(:nomis_concrete_slot, date: Date.new(2016, 3, 2), start_hour: 13, start_minute: 30, end_hour: 14, end_minute: 30),
                 build(:nomis_concrete_slot, date: Date.new(2016, 3, 3), start_hour: 13, start_minute: 30, end_hour: 14, end_minute: 30)
               ]).tap { |prison|
          switch_feature_flag_with(:public_prisons_with_slot_availability, [prison.name])
        }
      }

      before do
        stub_request(:get, "#{AuthHelper::API_PREFIX}/lookup/active_offender?date_of_birth=#{prisoner.date_of_birth}&noms_id=#{prisoner.number}").
          to_return(body: { found: true, offender: { id: offender_id } }.to_json)

        stub_request(:get, "#{AuthHelper::API_PREFIX}/offenders/#{offender_id}/visits/available_dates?end_date=2016-03-08&start_date=2016-02-13").
          to_return(body: { dates: ['2016-02-15'] }.to_json)

        stub_request(:get, "#{AuthHelper::API_PREFIX}/prison/#{prison.nomis_id}/slots?end_date=2016-03-12&start_date=2016-02-13").
          to_return(body: { slots: [
            { time: "2016-02-15T13:30/14:30" },
            { time: "2016-03-02T13:30/14:30" },
            { time: "2016-03-03T13:30/14:30" },
          ] }.to_json)

        switch_feature_flag_with(:public_prisons_with_slot_availability, [prison.name])
        Rails.configuration.vsip_host = nil
      end

      it 'returns the list of slots with their availabilities' do
        expect(described_class.slots(prison.id, prisoner.number, prisoner.date_of_birth, start_date, end_date)).
          to eq(slots)
      end
    end

    context 'with auto slots disabled' do
      let(:prison) { create(:staff_prison) }

      before do
        stub_request(:get, "#{AuthHelper::API_PREFIX}/offenders/#{offender_id}/visits/available_dates?end_date=2016-03-08&start_date=2016-02-09").
          to_return(body: { dates: ['2016-02-15'] }.to_json)

        stub_request(:get, "#{AuthHelper::API_PREFIX}/lookup/active_offender?date_of_birth=#{prisoner.date_of_birth}&noms_id=#{prisoner.number}").
          to_return(body: { found: true, offender: { id: offender_id } }.to_json)

        switch_feature_flag_with(:public_prisons_with_slot_availability, [])
        Rails.configuration.vsip_host = nil
      end

      it 'returns the list of slots with their availabilities' do
        expect(described_class.slots(prison.id, prisoner.number, prisoner.date_of_birth, start_date, end_date)).
          to eq({ "2016-02-15T14:00/16:10" => [],
                  "2016-02-16T09:00/10:00" => ["prisoner_unavailable"],
                  "2016-02-16T14:00/16:10" => ["prisoner_unavailable"],
                  "2016-02-22T14:00/16:10" => ["prisoner_unavailable"],
                  "2016-02-23T09:00/10:00" => ["prisoner_unavailable"],
                  "2016-02-23T14:00/16:10" => ["prisoner_unavailable"],
                  "2016-02-29T14:00/16:10" => ["prisoner_unavailable"],
                  "2016-03-01T09:00/10:00" => ["prisoner_unavailable"],
                  "2016-03-01T14:00/16:10" => ["prisoner_unavailable"],
                  "2016-03-07T14:00/16:10" => ["prisoner_unavailable"],
                  "2016-03-08T09:00/10:00" => ["prisoner_unavailable"],
                  "2016-03-08T14:00/16:10" => ["prisoner_unavailable"] })
      end
    end
  end

  describe 'with vsip slots' do
    let(:parsed_body) { JSON.parse(response.body) }
    let(:prisoner)    { create(:prisoner) }
    let(:start_date)  { '2016-02-09' }
    let(:end_date) { '2016-04-15' }

    describe '#index' do
      before do
        stub_auth_token
        Rails.configuration.vsip_host = 'http://example.com'
      end

      context 'with no sessions' do
        let(:prison) { create(:staff_prison, estate: create(:staff_estate, vsip_supported: true)) }

        before do
          allow_any_instance_of(VsipSupportedPrisons).to receive(:supported_prisons)
          allow(VsipVisitSessions).to receive(:get_sessions).and_return({})
        end

        it 'returns the list of slots with their availabilities' do
          expect(described_class.slots(prison.id, prisoner.number, prisoner.date_of_birth, start_date, end_date)).
            to eq({})
        end
      end

      context 'with one sessions' do
        let(:prison) { create(:staff_prison, estate: create(:staff_estate, vsip_supported: true)) }
        let(:first_session_start) { Time.zone.now + Random.rand(30).days }
        let(:second_session_start) { Time.zone.now + Random.rand(30).days }
        let(:expected_slots) {
          {
            create_slot(first_session_start) => [],
          }
        }

        before do
          allow_any_instance_of(VsipSupportedPrisons).to receive(:supported_prisons)
          allow(VsipVisitSessions).to receive(:get_sessions).and_return(expected_slots)
        end

        it 'returns the list of slots with their availabilities' do
          expect(described_class.slots(prison.id, prisoner.number, prisoner.date_of_birth, start_date, end_date)).
            to eq(expected_slots)
        end
      end

      context 'with multiple sessions' do
        let(:prison) { create(:staff_prison, estate: create(:staff_estate, vsip_supported: true)) }
        let(:first_session_start) { Time.zone.now + Random.rand(30).days }
        let(:second_session_start) { Time.zone.now + Random.rand(30).days }
        let(:expected_slots) {
          {
            create_slot(first_session_start) => [],
            create_slot(second_session_start) => []
          }
        }

        before do
          allow_any_instance_of(VsipSupportedPrisons).to receive(:supported_prisons)
          allow(VsipVisitSessions).to receive(:get_sessions).and_return(expected_slots)
        end

        it 'returns the list of slots with their availabilities' do
          expect(described_class.slots(prison.id, prisoner.number, prisoner.date_of_birth, start_date, end_date)).
            to eq(expected_slots)
        end
      end
    end
  end
end

def create_slot(start_time)
  "#{Time.zone.parse(start_time.to_s).
         strftime('%Y-%m-%dT%H:%M')}/#{Time.zone.parse((start_time + 1.hour).to_s).strftime('%H:%M')}"
end
