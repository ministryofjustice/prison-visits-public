class Prison
  include NonPersistedModel

  MAX_VISITORS = 6

  attribute :id, String
  attribute :name, String
  attribute :address, String
  attribute :postcode, String
  attribute :email_address, String
  attribute :phone_no, String

  def finder_slug
    'TODO' # Not yet reported by API
  end

  def self.find_by_id(id)
    result = Rails.configuration.api.get("/prisons/#{id}")
    Prison.new(result['prison'])
  end

  def self.all
    result = Rails.configuration.api.get('/prisons')
    result['prisons'].map { |params| Prison.new(params) }
  end
end
