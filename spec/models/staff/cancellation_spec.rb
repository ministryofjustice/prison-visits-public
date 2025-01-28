require 'rails_helper'

RSpec.describe Staff::Cancellation, :model do
  subject { build(:cancellation, visit: create(:staff_visit)) }

  describe 'validation' do
    context 'with empty strings' do
      before do
        subject.reasons = ['', described_class::PRISONER_VOS]
      end

      it { is_expected.to be_valid }
    end

    it 'enforces no more than one per visit' do
      cancellation = create(:cancellation, visit: create(:staff_visit))
      expect { create(:cancellation, visit: cancellation.visit) }.to raise_exception(ActiveRecord::RecordNotUnique)
    end

    it 'enforces the foreign key constraint' do
      expect { create(:cancellation, visit_id: SecureRandom.uuid) }.to raise_exception(ActiveRecord::InvalidForeignKey)
    end

    describe '#reasons' do
      context 'with rejection reasons' do
        before do
          subject.reasons = reasons
        end

        context 'when the reason does not exists' do
          let(:reasons) { ['invalid_reason'] }

          it 'for an invalid reason' do
            expect(subject).not_to be_valid
            expect(subject.errors.full_messages_for(:reasons)).to eq(
              ['Reasons invalid_reason is not in the list']
            )
          end
        end

        context 'when the reason exists' do
          let(:reasons) do
            described_class::REASONS[0..rand(described_class::REASONS.length - 1)]
          end

          it { is_expected.to be_valid }
        end
      end

      describe 'without a reason' do
        before do
          subject.reasons.clear
          expect(subject).to be_invalid
        end

        it 'has a meaning full translated message' do
          errors = subject.errors[:reasons]
          expect(errors).to eq(['Please provide a cancellation reason'])
        end
      end
    end
  end
end
