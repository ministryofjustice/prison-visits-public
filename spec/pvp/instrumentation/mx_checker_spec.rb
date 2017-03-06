require "rails_helper"

RSpec.describe Instrumentation::MxChecker do
  let(:nowish) { Time.now }
  let(:start)  { nowish }
  let(:finish) { nowish + 0.5 }

  describe '#process' do
    it "appends request time to the total request time" do
      expect(PVB::Instrumentation.custom_log_items).to include(mx: 500)
      expect(PVB::Instrumentation.logger)
        .to receive(:info).with('Validating email address MX record: - 500.00ms')
      subject.process
    end
  end
end
