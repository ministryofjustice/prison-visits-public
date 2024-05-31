require 'rails_helper'

RSpec.describe Message, type: :model do
  describe '.create_and_send_email' do
    subject { described_class.create_and_send_email(attrs) }

    let(:visitor) { create(:staff_visitor) }
    let(:visit) { create(:staff_visit, visitors: [visitor]) }
    let(:user) { FactoryBot.create(:user) }

    let(:attrs) do
      {
        visit:,
        user:,
        body: message_body
      }
    end

    before do
      allow(GovNotifyEmailer).to receive(:new).and_return(GovNotifyEmailerMock.new)
    end

    context 'when is a valid message' do
      let(:message_body) { 'Hello' }

      it 'creates a message' do
        expect { subject }.to change { visit.messages.count }.by(1)
      end
    end

    context 'when is not a valid message' do
      let(:message_body) { nil }

      it 'does not create a message' do
        expect { subject }.not_to change(visit, :messages)
      end
    end
  end
end
