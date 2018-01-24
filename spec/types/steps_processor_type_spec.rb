require 'rails_helper'

RSpec.describe StepsProcessorType do
  describe '#cast' do
    context 'when the value is a steps processor' do
      let(:value) { StepsProcessor.new({}, :en) }

      it { expect(subject.cast(value)).to eq(value) }
    end

    context 'when is something else' do
      let(:value) { anything }

      it { expect { subject.cast(value) }.to raise_error(ArgumentError) }
    end
  end
end
