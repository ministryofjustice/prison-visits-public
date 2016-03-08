class Prison
  include NonPersistedModel

  attribute :id, String
  attribute :name, String
  attribute :address, String
  attribute :postcode, String
  attribute :email_address, String
  attribute :phone_no, String
  attribute :prison_finder_url, String

  def self.find_by_id(id)
    Rails.configuration.pvb_api.get_prison(id)
  end

  def self.all
    Rails.configuration.pvb_api.get_prisons
  end
end
