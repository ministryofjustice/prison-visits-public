class SlotConstraints
  include Enumerable
  delegate :each, to: :@calendar_slots

  def initialize(calendar_slots)
    @calendar_slots = calendar_slots
  end

  def bookable_date?(requested_date)
    bookable_slots.any? do |slot_availability|
      slot_availability.slot.to_date == requested_date
    end
  end

  def bookable_slot?(requested_slot)
    bookable_slots.any? do |slot_availability|
      slot_availability.slot == requested_slot
    end
  end

  def last_bookable_date
    bookable_slots.max.to_date
  end

  def bookable_slots?
    bookable_slots.any?
  end

  def unavailability_reasons(slot)
    find { |calendar_slot| calendar_slot.slot == slot }.unavailability_reasons
  end

  def bookable_slots
    @bookable_slots ||= select(&:bookable?)
  end
end
