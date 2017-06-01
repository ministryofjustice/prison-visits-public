require 'spec_helper'
require 'rails_helper'

RSpec.describe FeedbackSubmission, type: :model do
  let(:body) { 'Feedback' }
  let(:email_address) { nil }
  let(:prisoner_number) { nil }
  let(:date_of_birth) { nil }
  let(:prison_id) { nil }

  subject(:instance) do
    described_class.new(
      body: body,
      email_address: email_address,
      prisoner_number: prisoner_number,
      date_of_birth: date_of_birth,
      prison_id: prison_id
    )
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

    describe 'prisoner_number' do
      context 'is blank' do
        let(:prisoner_number) { nil }
        it { expect(subject.errors[:prisoner_number]).not_to be_present }
      end

      context 'is incorrect format' do
        let(:prisoner_number) { 'Goofy78' }
        it { expect(subject.errors[:prisoner_number]).to be_present }
      end

      context 'is correct format' do
        let(:prisoner_number) { 'A1234BC' }
        it { expect(subject.errors[:prisoner_number]).not_to be_present }
      end
    end

    describe 'date_of_birth' do
      context 'is blank' do
        let(:date_of_birth) { nil }
        it { expect(subject.errors[:date_of_birth]).not_to be_present }
      end

      context 'is a valid date' do
        let(:date_of_birth) { '1999-01-01' }
        it { expect(subject.errors[:date_of_birth]).not_to be_present }
      end

      context 'is an invalid date' do
        let(:date_of_birth) { '1800-12-25' }
        it { expect(subject.errors[:date_of_birth]).to be_present }
      end
    end

    describe 'prison_id' do
      context 'is blank' do
        let(:prison_id) { nil }
        it { expect(subject.errors[:prison_id]).not_to be_present }
      end
    end
  end
end
