module Staff
  class Slots
    def self.slots(prison_id, prisoner_number, date_of_birth, start_date, end_date)
      # get and set Vsip supported prisons
      VsipSupportedPrisons.new.supported_prisons unless Rails.configuration.vsip_supported_prisons_retrieved

      prison = Staff::Prison.enabled.find(prison_id)
      prison.vsip_failed = false

      if prison.estate.vsip_supported
        @slots = VsipVisitSessions.get_sessions(prison.estate.nomis_id, prisoner_number)
        if @slots[:vsip_api_failed]
          prison.vsip_failed = true
          @slots = SlotAvailability.new(prison, prisoner_number, date_of_birth, start_date..end_date).slots
        end
      elsif prison.auto_slots_enabled?
        api_slots = ApiSlotAvailability.new(prison:, use_nomis_slots: true, start_date:, end_date:)
        prisoner_dates = api_slots.prisoner_available_dates(prisoner_number:, prisoner_dob: date_of_birth, start_date:)
        @slots = api_slots.slots.map { |slot| [slot.to_s, prisoner_dates.include?(slot.to_date) ? [] : [SlotAvailability::PRISONER_UNAVAILABLE]] }.to_h
      else
        @slots = SlotAvailability.new(prison, prisoner_number, date_of_birth, start_date..end_date).slots
      end
    end
  end
end
