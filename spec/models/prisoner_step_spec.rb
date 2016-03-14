require 'rails_helper'

RSpec.describe PrisonerStep do
  subject { described_class.new(params) }

  let(:params) { { prison_id: '123' } }
  let(:prison) { Prison.new(name: 'Reading Gaol') }
  let(:pvb_api) { Rails.configuration.pvb_api }

  before do
    allow(pvb_api).to receive(:get_prison).and_return(prison)
  end

  it 'uses the API in order to determine prison name' do
    expect(pvb_api).to receive(:get_prison).and_return(prison)
    expect(subject.prison_name).to eq('Reading Gaol')
  end
end
