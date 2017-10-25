require 'rails_helper'

RSpec.describe Healthcheck::PvbApiCheck do
  subject { described_class.new('PVB API Check') }

  context 'with a healthy API' do
    before do
      allow_any_instance_of(PrisonVisits::Client).
        to receive(:healthcheck).
        and_return(double(status: 200))
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
        allow_any_instance_of(PrisonVisits::Client).
          to receive(:healthcheck).
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
        allow_any_instance_of(PrisonVisits::Client).
          to receive(:healthcheck).
          and_return(double(status: 500))
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
