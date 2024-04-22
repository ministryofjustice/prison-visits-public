module Staff
  class Slots
    def self.slots(prison_id, prisoner_number, date_of_birth, start_date, end_date)
      prison = Staff::Prison.enabled.find(prison_id)

      if prison.auto_slots_enabled?
        api_slots = ApiSlotAvailability.new(prison:, use_nomis_slots: true, start_date:, end_date:)
        prisoner_dates = api_slots.prisoner_available_dates(prisoner_number:, prisoner_dob: date_of_birth, start_date:)
        @slots = api_slots.slots.map { |slot| [slot.to_s, prisoner_dates.include?(slot.to_date) ? [] : [SlotAvailability::PRISONER_UNAVAILABLE]] }.to_h
      else
        @slots = SlotAvailability.new(prison, prisoner_number, date_of_birth, start_date..end_date).slots
      end
    end
  end
end
