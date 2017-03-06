require "rails_helper"

RSpec.describe PVP::Instrumentation::MxChecker do
  let(:nowish) { Time.now }
  let(:start)  { nowish }
  let(:finish) { nowish + 0.5 }
  let(:event)  do
    ActiveSupport::Notifications::Event.new(
      :mx, start, finish, '_id', category: :mx
    )
  end

  subject { described_class.new(event) }

  describe '#process' do
    it "appends request time to the total request time" do
      expect(PVB::Instrumentation.logger).
        to receive(:info).with('Validating email address MX record: - 500.00ms')
      subject.process
      expect(PVB::Instrumentation.custom_log_items).to include(mx: 500)
    end
  end
end
