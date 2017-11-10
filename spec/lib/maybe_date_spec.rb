require 'maybe_date'

RSpec.describe MaybeDate do
  subject { described_class.new(Axiom::Types::Object, options) }

  let(:options) do
    { default_value: nil, coercer: nil }
  end

  describe '#coerce' do
    let(:result) { subject.coerce(value) }

    context 'when the value is nil' do
      let(:value) { nil }

      it 'returns nil' do
        expect(result).to eq(nil)
      end
    end

    context 'when the value is a Date' do
      let(:value) { Date.new(2000, 1, 1) }

      it 'returns the value unchanged' do
        expect(result).to eq(value)
      end
    end

    context 'when the value is a String' do
      let(:value) { '2000-01-01' }

      it 'returns the string parsed to a date' do
        expect(result).to eq(Date.new(2000, 1, 1))
      end
    end

    context 'when the value responds to values_at' do
      let(:value) { double('Thing', values_at: values) }

      context 'when returning zero values' do
        let(:values) { %w[0 0 0] }

        it 'returns nil' do
          expect(result).to eq(nil)
        end
      end

      context 'when the returning values corresponding to a valid date' do
        let(:values) { %w[2015 12 31] }

        it 'returns the date' do
          expect(result).to eq(Date.new(2015, 12, 31))
        end
      end

      context 'when the returning values corresponding to an invalid date' do
        let(:values) { %w[2015 12 32] }

        it 'returns an uncoerced date object' do
          expect(result.year).to eq(2015)
          expect(result.month).to eq(12)
          expect(result.day).to eq(32)
        end
      end
    end
  end
end
