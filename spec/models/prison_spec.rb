require 'rails_helper'

RSpec.shared_examples_for 'disabled prison' do
  it "is false" do
    expect(subject.enabled?).to be false
  end
end

RSpec.describe Prison do
  subject { described_class.new(params) }

  let(:params) { Hash.new }

  describe 'all' do
    it 'fetches a list of prisons from API' do
      expect(pvb_api).to receive(:get_prisons)
      described_class.all
    end
  end

  describe 'find_by_id' do
    it 'fetches prison info from API' do
      expect(pvb_api).to receive(:get_prison).with('123')
      described_class.find_by_id('123')
    end
  end

  describe '#enabled?' do
    context 'when disabled' do
      before do
        params[:enabled] = false
      end

      it 'is false' do
        expect(subject).to_not be_enabled
      end
    end

    context 'when enabled' do
      context 'when set' do
        before do
          params[:enabled] = true
        end

        it 'is true' do
          expect(subject).to be_enabled
        end
      end

      context 'when not set' do
        before do
          params[:enabled] = nil
        end

        it 'is true' do
          expect(subject).to be_enabled
        end
      end
    end
  end

  it "allows initialisation with and reading of attributes" do
    params[:name] = 'Reading Gaol'
    expect(subject.name).to eq('Reading Gaol')
  end

  it 'discards unspecified attributes' do
    params[:foo] = 'bar'
    expect {
      subject.foo
    }.to raise_error(NoMethodError)
  end
end
