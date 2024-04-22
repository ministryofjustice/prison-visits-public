require 'rails_helper'

RSpec.describe Staff::PrisonerValidator do
  describe 'validate' do
    context 'when validating correctly' do
      before do
        allow(Staff::ApiPrisonerChecker).to receive(:new).and_return(OpenStruct.new({ valid?: true }))
      end

      it 'passes through true' do
        expect(described_class.validate(1, 1)).to be_truthy
      end
    end

    context 'when validating incorrectly' do
      before do
        allow(Staff::ApiPrisonerChecker).to receive(:new).and_return(OpenStruct.new({ valid?: false, error: :error }))
      end

      it 'passes through the error' do
        expect(described_class.validate(1, 1)[:errors]).to eq([:error])
      end
    end
  end
end
