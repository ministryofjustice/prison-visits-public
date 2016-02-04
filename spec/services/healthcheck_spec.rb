require 'rails_helper'

RSpec.describe Healthcheck do
  let(:database_check) {
    instance_double(Healthcheck::DatabaseCheck, ok?: database_ok, report: database_report)
  }
  let(:zendesk_check) {
    instance_double(Healthcheck::QueueCheck, ok?: zendesk_ok, report: zendesk_report)
  }

  let(:database_report) { { description: 'database', ok: database_ok } }
  let(:zendesk_report) { { description: 'zendesk', ok: zendesk_ok } }

  before do
    allow(Healthcheck::DatabaseCheck).to receive(:new).
      and_return(database_check)
    allow(Healthcheck::QueueCheck).to receive(:new).
      with(anything, queue_name: 'zendesk').and_return(zendesk_check)
  end

  context 'when everything is OK' do
    let(:database_ok) { true }
    let(:zendesk_ok) { true }

    it { is_expected.to be_ok }

    it 'combines the reports' do
      expect(subject.checks).to eq(
        ok: true,
        zendesk: zendesk_report,
        database: database_report
      )
    end
  end

  context 'when there is a problem' do
    let(:database_ok) { false }
    let(:zendesk_ok) { true }

    it { is_expected.not_to be_ok }

    it 'combines the reports' do
      expect(subject.checks).to eq(
        ok: false,
        zendesk: zendesk_report,
        database: database_report
      )
    end
  end
end
