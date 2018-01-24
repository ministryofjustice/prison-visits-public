require 'rails_helper'

RSpec.describe VisitorList do
  let(:visitor1) { Visitor.new }
  let(:visitor2) { Visitor.new }

  subject { described_class.new([visitor1, visitor2]) }

  describe '.new' do
    context 'when the visitors contains other classes' do
      let(:args) { ['foo'] }

      it { expect { described_class.new(args) }.to raise_error(ArgumentError) }
    end
  end

  it { expect(described_class.ancestors).to include(Enumerable) }
  it { expect(subject.to_a).to contain_exactly(visitor1, visitor2) }
end
