require 'rails_helper'

RSpec.describe Healthcheck::PvbApiCheck do
  subject { described_class.new('PVB API Check') }

  context 'with a healthy API' do
    before do
      allow(PrisonVisits::Api.instance).
        to receive(:healthy?).
        and_return(true)
    end

    it { is_expected.to be_ok }

    it 'reports the status' do
      expect(subject.report).to eq(
        description: 'PVB API Check',
        ok: true
      )
    end
  end

  context 'with an unhealthy API' do
    context 'that raises an error' do
      before do
        allow(PrisonVisits::Api.instance).
          to receive(:healthy?).
          and_raise(StandardError, 'some other exception')
      end

      it { is_expected.to_not be_ok }

      it 'reports the error' do
        expect(subject.report).to eq(
          description: 'PVB API Check',
          ok: false,
          error: 'some other exception'
        )
      end
    end

    context 'that reports the status' do
      before do
        allow(PrisonVisits::Api.instance).
          to receive(:healthy?).
          and_return(false)
      end

      it { is_expected.to_not be_ok }

      it 'reports the status' do
        expect(subject.report).to eq(
          description: 'PVB API Check',
          ok: false
        )
      end
    end
  end
end
