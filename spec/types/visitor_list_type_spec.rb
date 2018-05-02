require 'rails_helper'

RSpec.describe VisitorListType do
  describe '#cast' do
    let(:value) { [{ first_name: 'foo' }, { first_name: 'bar' }] }

    it { expect(subject.cast(value)).to all(be_instance_of(Visitor)) }
  end
end
