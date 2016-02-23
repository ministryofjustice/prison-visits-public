class Visit
  include NonPersistedModel

  attribute :id
  attribute :confirm_by, Date
  attribute :contact_email_address
  attribute :slots, [ConcreteSlot], coercer: lambda { |slots|
    slots.map { |s| ConcreteSlot.parse(s) }
  }
  attribute :prison_id

  delegate :address, :email_address, :name, :phone_no, :postcode,
    to: :prison, prefix: true
  delegate :prison_finder_url, to: :prison

  def prison
    # Memoize since this does an API lookup
    @_prison ||= Prison.find_by_id(prison_id)
  end
end
