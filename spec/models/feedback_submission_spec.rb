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
      context 'when is not present' do
        let(:email_address) { '' }
        it { expect(subject.errors[:email_address]).to be_empty }
      end

      context 'with valid format' do
        let(:email_address) { 'user@example.com' }
        it { expect(subject.errors[:email_address]).to be_empty }
      end

      context 'with invalid format' do
        let(:email_address) { 'random email' }
        it { expect(subject.errors[:email_address]).to be_present }
      end
    end
  end

  describe '#send_feedback' do
    it 'sends the feedback data via the api' do
      expect(PrisonVisits::Api.instance).
        to receive(:create_feedback) do |arg|
        expect(arg[:feedback][:body]).to eq(body)
        expect(arg[:feedback][:email_address]).to eq(email_address)
        expect(arg[:feedback][:referrer]).to eq(instance.referrer)
        expect(arg[:feedback][:user_agent]).to eq(instance.user_agent)
      end

      instance.send_feedback
    end
  end
end
