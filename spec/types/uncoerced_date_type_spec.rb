require 'rails_helper'

RSpec.describe UncoercedDateType do
  describe '#cast' do
    context 'when the value is a Date' do
      let(:value) { Date.new(2018, 01, 23) }
      let(:uncoerced_date) { UncoercedDate.new(2018, 01, 23) }

      it { expect(subject.cast(value)).to eq(uncoerced_date) }
    end

    context 'when the value is a hash' do
      describe 'non zero values' do
        let(:value) { { year: '2018', month: '1', day: '12' } }
        let(:uncoerced_date) { UncoercedDate.new(2018, 01, 12) }

        it { expect(subject.cast(value)).to eq(uncoerced_date) }
      end

      describe 'zero values' do
        let(:value) { { year: '0', month: '0', day: '0' } }

        it { expect(subject.cast(value)).to be_nil }
      end
    end
  end
end
