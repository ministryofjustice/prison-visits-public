require 'rails_helper'

RSpec.describe BookingRequestCreator do
  let(:prisoner_step) {
    PrisonerStep.new(
      prison_id: 'PRISONID',
      first_name: 'Oscar',
      last_name: 'Wilde',
      date_of_birth: Date.new(1980, 12, 31),
      number: 'a1234bc'
    )
  }

  let(:visitors_step) {
    VisitorsStep.new(
      email_address: 'ada@test.example.com',
      phone_no: '01154960222',
      visitors: [
        {
          first_name: 'Ada',
          last_name: 'Lovelace',
          date_of_birth: Date.new(1970, 11, 30)
        },
        {
          first_name: 'Charlie',
          last_name: 'Chaplin',
          date_of_birth: Date.new(2005, 1, 2)
        }
      ]
    )
  }

  let(:slots_step) {
    SlotsStep.new(
      option_0: '2015-01-02T09:00/10:00',
      option_1: '2015-01-03T09:00/10:00',
      option_2: '2015-01-04T09:00/10:00'
    )
  }

  it 'calls the API to create a booking request using the provided steps' do
    expect(Rails.configuration.pvb_api).to receive(:request_booking).with(
      prison_id: "PRISONID",
      prisoner: {
        first_name: "Oscar",
        last_name: "Wilde",
        date_of_birth: Date.new(1980, 12, 31),
        number: "a1234bc"
      },
      visitors: [{
        first_name: "Ada",
        last_name: "Lovelace",
        date_of_birth: Date.new(1970, 11, 30)
      }, {
        first_name: "Charlie",
        last_name: "Chaplin",
        date_of_birth: Date.new(2005, 1, 2)
      }],
      contact_email_address: "ada@test.example.com",
      contact_phone_no: "01154960222",
      slot_options: [
        "2015-01-02T09:00/10:00",
        "2015-01-03T09:00/10:00",
        "2015-01-04T09:00/10:00"
      ],
      locale: :cy
    )

    subject.create! prisoner_step, visitors_step, slots_step, :cy
  end
end
