require 'spec_helper'
require 'rails_helper'

RSpec.describe FeedbackSubmission, type: :model do
  let(:body) { 'Feedback' }
  let(:email_address) { nil }

  subject(:instance) do
    described_class.new(body: body, email_address: email_address)
  end

  describe '#email=' do
    it "doesn't strip nil values" do
      subject.email_address = nil
      expect(subject.email_address).to be_nil
    end

    it 'strips whitespace' do
      subject.email_address = ' user@example.com '
      expect(subject.email_address).to eq('user@example.com')
    end
  end

  describe 'validations' do
    before do
      subject.valid?
    end

    context 'body' do
      describe 'is blank' do
        let(:body) { nil }

        it { expect(subject.errors[:body]).to be_present }
      end
    end

    describe 'email_address' do
      it 'is valid when absent' do
        subject.email_address = ''
        subject.valid?
        expect(subject.errors).not_to have_key(:email_address)
      end

      context 'when the email checker returns true' do
        before do
          allow_any_instance_of(EmailChecker).
            to receive(:valid?).and_return(true)
        end

        it 'is valid' do
          subject.email_address = 'user@test.example.com'
          subject.valid?
          expect(subject.errors).not_to have_key(:email_address)
        end
      end

      context 'when the email checker returns false' do
        before do
          allow_any_instance_of(EmailChecker).
            to receive(:valid?).and_return(false)
        end

        it 'is invalid when not an email address' do
          subject.email_address = 'BOGUS !'
          subject.valid?
          expect(subject.errors).to have_key(:email_address)
        end
      end
    end
  end
end
