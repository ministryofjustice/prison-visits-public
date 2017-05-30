class CalendarSlot
  include NonPersistedModel
  include Comparable

  delegate :begin_at, :iso8601, :to_date, to: :slot
  attribute :slot, ConcreteSlot
  attribute :unavailability_reasons, Array[String], default: []

  def bookable?
    unavailability_reasons.empty?
  end

  def <=>(other)
    slot <=> other.slot
  end
end
