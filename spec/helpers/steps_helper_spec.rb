require 'rails_helper'

RSpec.describe StepsHelper do
  describe '#additional_visitor_selections' do
    let(:step) { double("Step", max_visitors: 3) }

    subject { helper.additional_visitor_selections(step) }

    it { is_expected.to contain_exactly(['0', 0], ['1', 1], ['2', 2]) }
  end
end
