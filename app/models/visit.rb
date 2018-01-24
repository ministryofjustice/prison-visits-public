class Visit
  include NonPersistedModel

  VALID_STATES = %i[ requested withdrawn booked cancelled rejected ].freeze

  attribute :id, :string
  attribute :human_id, :string
  attribute :confirm_by, :date
  attribute :slot_granted, :concrete_slot
  attribute :contact_email_address, :string
  attribute :slots, :concrete_slot_list
  attribute :prison_id, :string
  attribute :processing_state, :immutable_string
  attribute :visitors, :visitor_list
  attribute :cancellation_reasons
  attribute :cancelled_at, :datetime
  attribute :can_cancel, :boolean
  attribute :can_withdraw, :boolean
  attribute :created_at, :datetime
  attribute :updated_at, :datetime
  attribute :messages

  delegate :address, :email_address, :name, :phone_no, :postcode,
    to: :prison, prefix: true
  delegate :prison_finder_url, to: :prison

  def allowed_visitors
    visitors.select(&:allowed)
  end

  def rejected_visitors
    visitors.reject(&:allowed)
  end

  def can_cancel?
    can_cancel
  end

  def can_withdraw?
    can_withdraw
  end

  def processing_state
    # attribute(:processing_state).to_sym RAILS 5.2
    super.to_sym
  end

private

  def prison
    # Memoize since this does an API lookup
    @_prison ||= Prison.find_by_id(prison_id)
  end
end
