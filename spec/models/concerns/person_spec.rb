require 'rails_helper'

RSpec.describe Person do
  subject {
    described_module = described_class
    Class.new {
      include MemoryModel
      include described_module

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :date_of_birth, :date

      def self.model_name
        ActiveModel::Name.new(self, nil, 'thing')
      end
    }.new
  }

  around do |example|
    travel_to Date.new(2015, 10, 8) do
      example.run
    end
  end

  describe 'full_name' do
    it 'joins first and last name' do
      subject.first_name = 'Oscar'
      subject.last_name = 'Wilde'
      expect(subject.full_name).to eq('Oscar Wilde')
    end
  end
end
