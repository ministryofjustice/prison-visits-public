require 'rails_helper'

RSpec.describe Staff::VisitorsValidator do
  let(:prison) { create :staff_prison }

  describe 'validate' do
    before do
      allow(Staff::Prison).to receive(:find).and_return(prison)
    end

    context 'valid' do
      it 'validates a visitor' do
        expect(described_class.validate(1, '1/1/2000', [Time.zone.today - 3.days])).
          to eq({ validation: { "valid" => true } })
      end

      context 'invalid' do
        it 'validates a visitor who is not valid' do
          expect(described_class.validate(1, '1/1/2000',
                                          [Time.zone.today - 20.years,
                                           Time.zone.today - 20.years,
                                           Time.zone.today - 20.years,
                                           Time.zone.today - 20.years])).
            to eq({ validation: { :errors => ["too_many_adults"], "valid" => false } })
        end
      end

      context 'invalid date format' do
        it 'validates a visitor who is not valid' do
          expect {
            described_class.validate(1, '1/1/2000',
                                     ['a/a/a'])
          }.to raise_error(Staff::VisitorsValidator::ParameterError)
        end
      end
    end
  end
end
