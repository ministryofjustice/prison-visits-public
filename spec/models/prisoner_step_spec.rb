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

  it 'uses the PVB API to validate that the prisoner exists' do
    expect(pvb_api).to receive(:validate_prisoner).with(
      number: 'a1234bc',
      date_of_birth: Date.new(1970, 12, 31)
    ).and_return('valid' => true)
    expect(subject.valid?).to be true
  end

  it 'fails validation if PVB API returns prisoner_does_not_exist error' do
    expect(pvb_api).to receive(:validate_prisoner).and_return(
      'valid' => false,
      'errors' => ['prisoner_does_not_exist']
    )
    expect(subject.valid?).to be false
    expect(subject.errors.messages).to have_key(:number)
    expect(subject.errors.messages).to have_key(:date_of_birth)
  end

  it 'does not call the PVB API if the date is invalid' do
    params[:date_of_birth][:month] = '13'
    expect(pvb_api).not_to receive(:validate_prisoner)
    expect(subject.valid?).to be false
  end
end
