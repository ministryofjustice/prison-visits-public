# :nocov:
# Ignoring this for coverage as only brought to support testing when moved from staff to public app.  Not used in the
# by the pubic app in requesting a visit, but kept in for future reference.
#
class SlotAvailability
  PRISONER_UNAVAILABLE = 'prisoner_unavailable'.freeze
  PRISON_UNAVAILABLE   = 'prison_unavailable'.freeze

  def initialize(prison, noms_id, date_of_birth,
    date_range = Time.zone.today.to_date..28.days.from_now)
    @prison = prison
    @noms_id = noms_id
    @date_of_birth = date_of_birth
    @start_date = date_range.min
    @end_date = calculate_end_date(date_range)
  end

  def slots
    all_slots.deep_dup.each do |slot, unavailability_reasons|
      if prisoner_unavailable?(slot)
        unavailability_reasons << PRISONER_UNAVAILABLE
      end

      if prison_unavailable?(slot)
        unavailability_reasons << PRISON_UNAVAILABLE
      end
    end
  end

private

  def all_slots
    @all_slots ||= Hash[prison_slots.map { |slot| [slot.to_s, []] }]
  end

  attr_reader :prison, :noms_id, :date_of_birth, :start_date, :end_date

  def prisoner_unavailable?(slot)
    Nomis::Api.enabled? &&
      prisoner.valid? &&
      !prisoner_availability_dates.include?(slot.to_date)
  end

  def prison_unavailable?(slot)
    live_availability_enabled? && slot_availability.slot_error(slot)
  end

  def prisoner
    @prisoner ||= Nomis::Api.instance.lookup_active_prisoner(
      noms_id:, date_of_birth:
    )
  end

  def prison_slots
    @prison_slots ||= prison.available_slots(start_date)
  end

  def slot_availability
    @slot_availability ||= SlotAvailabilityValidation.new(
      prison:,
      requested_slots: prison_slots
    ).tap(&:valid?)
  end

  def prisoner_availability
    @prisoner_availability ||=
      begin
        Nomis::Api.instance.prisoner_visiting_availability(
          offender_id: prisoner.nomis_offender_id,
          start_date:,
          end_date:
        )
      rescue Nomis::APIError => e
        Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
        Nomis::PrisonerAvailability.new(dates: all_slots.keys.uniq)
      end
  end

  def prisoner_availability_dates
    @prisoner_availability_dates ||= prisoner_availability.dates
  end

  def calculate_end_date(date_range)
    # ensures the range does not go over the 28 days constraint
    [date_range.min + 28.days, date_range.max].min
  end

  def live_availability_enabled?
    Nomis::Api.enabled? &&
      Rails.configuration.public_prisons_with_slot_availability.include?(prison.name)
  end
end
