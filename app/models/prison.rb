class Prison
  include NonPersistedModel

  attribute :id, String
  attribute :name, String

  def self.all
    result = Rails.configuration.api.get('/prisons')
    result['prisons'].map { |params| Prison.new(params) }
  end
end
