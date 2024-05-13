require 'rails_helper'

RSpec.describe Staff::VisitsManager do
  describe 'with nomis autoupdate and hardcoded slots for create' do
    let(:visit) { create(:staff_visit) }
    let(:prison) do
      create(
        :staff_prison,
        slot_details: { 'recurring' => { 'mon' => ['1330-1430'] } },
      )
    end

    let(:parsed_body) {
      JSON.parse(response.body)
    }

    around do |example|
      travel_to Time.zone.local(2016, 2, 3, 14, 0) do
        example.run
      end
    end

    before do
      allow_any_instance_of(GovNotifyEmailer).to receive(:send_email)
    end

    describe 'create' do
      let(:params) {
        {
          format: :json,
          prison_id: prison.id,
          prisoner: {
            first_name: 'Joe',
            last_name: 'Bloggs',
            date_of_birth: '1980-01-01',
            number: 'A1234BC'
          },
          visitors: [
            {
              first_name: 'Joe',
              last_name: 'Bloggs',
              date_of_birth: '1980-01-01'
            }
          ],
          slot_options: [
            '2016-02-15T13:30/14:30'
          ],
          contact_email_address: 'foo@example.com',
          contact_phone_no: '1234567890'
        }
      }

      describe 'when successfull' do
        it 'creates a new visit booking request' do
          visit_count_before = Staff
          ::Visit.count
          described_class.new.create(params)
          visit_added = Staff::Visit.last

          expect(Staff::Visit.count).to eq(visit_count_before + 1)
          expect(visit_added.visitors[0][:first_name]).to eq(params[:visitors][0][:first_name])
        end
      end

      it 'fails if a (top-level) parameter is missing' do
        params.delete(:contact_email_address)

        expect { described_class.new.create(params) }.to raise_error(described_class::ParameterError,
                                                                     /Missing parameter: contact_email_address/)
      end

      it 'fails if the prisoner is invalid' do
        params[:prisoner][:first_name] = nil

        expect { described_class.new.create(params) }.to raise_error(described_class::ParameterError,
                                                                     /First name is required/)
      end

      it 'fails if the visitors are invalid' do
        params[:visitors][0][:first_name] = nil

        expect { described_class.new.create(params) }.to raise_error(described_class::ParameterError, /visitors/)
      end

      it 'fails if slot_options is not an array' do
        params[:slot_options] = 'string'

        expect { described_class.new.create(params) }.to raise_error(described_class::ParameterError,
                                                                     /slot_options must contain >= slot/)
      end

      it 'returns an error if the slot does not exist' do
        params[:slot_options] = ['2016-02-15T04:00/04:30']
        expect { described_class.new.create(params) }.to raise_error(described_class::ParameterError,
                                                                     /slot_options \(Option 0/)
      end
    end

    describe 'destroy' do
      let(:params) {
        {
          format: :json,
          id: visit.human_id
        }
      }

      let(:mailing) {
        double(Mail::Message, deliver_later: nil)
      }

      context 'with a booked visit' do
        let(:visit) { create(:booked_visit) }

        it 'cancels a visit request' do
          described_class.new.destroy(visit.human_id)

          expect(Staff::Visit.where(human_id: visit.human_id).first.processing_state).to eq('cancelled')
        end
      end

      context 'with a requested visit' do
        it 'withdraws the requested visit' do
          described_class.new.destroy(visit.human_id)
          described_class.new.destroy(visit.human_id)

          expect(Staff::Visit.where(human_id: visit.human_id).first.processing_state).to eq('withdrawn')
        end

        it 'fails if the visit does not exist' do
          expect(described_class.new.destroy("#{visit.human_id}_does_not_exit")).to be_falsey
        end
      end
    end
  end
end
