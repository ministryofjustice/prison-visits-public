require 'spec_helper'
require 'rails_helper'

RSpec.describe FeedbackSubmission, type: :model do
  context '#email=' do
    it "doesn't strip nil values" do
      subject.email_address = nil
      expect(subject.email_address).to be_nil
    end

    it 'strips whitespace' do
      subject.email_address = ' user@example.com '
      expect(subject.email_address).to eq('user@example.com')
    end
  end

  context 'validations' do
    it 'requires a body' do
      subject.body = nil
      subject.valid?
      expect(subject.errors[:body]).to be_present
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
