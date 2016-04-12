class Visit
  include NonPersistedModel

  attribute :id
  attribute :confirm_by, Date
  attribute :contact_email_address
  attribute :slots, [ConcreteSlot], coercer: lambda { |slots|
    slots.map { |s| ConcreteSlot.parse(s) }
  }
  attribute :prison_id
  attribute :processing_state, Symbol, coercer: lambda { |state|
    VALID_STATES.find { |s| s.to_s == state } ||
      fail("Invalid processing_state for visit: #{state}")
  }

  VALID_STATES = %i[ requested withdrawn booked cancelled rejected ]

  delegate :address, :email_address, :name, :phone_no, :postcode,
    to: :prison, prefix: true
  delegate :prison_finder_url, to: :prison

private

  def prison
    # Memoize since this does an API lookup
    @_prison ||= Prison.find_by_id(prison_id)
  end
end
