class Prison
  include NonPersistedModel

  attribute :id, String
  attribute :name, String
  attribute :address, String
  attribute :postcode, String
  attribute :closed, Boolean
  attribute :private, Boolean
  attribute :enabled, Boolean
  attribute :email_address, String
  attribute :phone_no, String
  attribute :prison_finder_url, String
  attribute :max_visitors, Integer
  attribute :adult_age, Integer

  def self.find_by_id(id)
    PrisonVisits::Api.instance.get_prison(id)
  end

  def closed?
    closed
  end

  def enabled?
    enabled
  end

  def self.all
    PrisonVisits::Api.instance.get_prisons
  end
end
