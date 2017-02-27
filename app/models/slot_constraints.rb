class SlotConstraints
  delegate :map, to: :@slot_calendars

  def initialize(slot_calendars)
    @slot_calendars = slot_calendars
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

private

  def bookable_slots
    @bookable_slots ||= @slot_calendars.select(&:bookable?)
  end
end
