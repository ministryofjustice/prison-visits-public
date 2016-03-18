require 'rails_helper'

RSpec.describe PrisonerStep do
  subject { described_class.new(params) }

  let(:params) {
    {
      first_name: 'Joe',
      last_name: 'Bloggs',
      date_of_birth: {
        day: '31',
        month: '12',
        year: '1970'
      },
      number: 'a1234bc',
      prison_id: '123'
    }
  }
  let(:prison) { Prison.new(name: 'Reading Gaol') }
  let(:pvb_api) { PrisonVisits::Api.instance }

  before do
    allow(pvb_api).to receive(:get_prison).and_return(prison)
  end

  it 'uses the API in order to determine prison name' do
    expect(pvb_api).to receive(:get_prison).and_return(prison)
    expect(subject.prison_name).to eq('Reading Gaol')
  end

  it 'does not fail if the date is invalid (anti-regression)' do
    params[:date_of_birth][:month] = '13'

    dob = subject.date_of_birth

    expect(dob).to be_kind_of(UncoercedDate)
    expect(dob.month).to eql(13)
  end
end
