class Prison
  include NonPersistedModel

  attribute :id, :string
  attribute :name, :string
  attribute :address, :string
  attribute :postcode, :string
  attribute :closed, :boolean
  attribute :private, :boolean
  attribute :enabled, :boolean
  attribute :email_address, :string
  attribute :phone_no, :string
  attribute :prison_finder_url, :string
  attribute :max_visitors, :integer
  attribute :adult_age, :integer
  attribute :prison_url, :string

  def self.find_by_id(id)
    PrisonVisits::Api.instance.get_prison(id)
  end

  def closed?
    closed
  end

  def private?
    private
  end

  # TODO: Remove nil check once pvb2 related PR has been deployed
  def enabled?
    enabled.nil? || enabled
  end

  def self.all
    PrisonVisits::Api.instance.get_prisons
  end
end
