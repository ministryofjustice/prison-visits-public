# Responsible for fetching constraints, potentially via API calls, and
# returning constraint objects
class BookingConstraints
  def initialize(prison: nil, prisoner_number: nil, prisoner_dob: nil)
    @prison = prison
    @prisoner_number = prisoner_number
    @prisoner_dob = prisoner_dob
  end

  def on_visitors
    VisitorConstraints.new(@prison)
  end

  def on_slots(use_nomis_slots = false)
    fail 'No prison' unless @prison
    fail 'No prisoner details' unless @prisoner_number && @prisoner_dob
    slots = PrisonVisits::Api.instance.get_slots(
      prison_id: @prison.id,
      prisoner_number: @prisoner_number,
      prisoner_dob: @prisoner_dob,
      use_nomis_slots: use_nomis_slots
    )
    SlotConstraints.new(slots)
  end

  class VisitorConstraints
    MAX_ADULTS = 3
    LEAD_VISITOR_MIN_AGE = 18

    def initialize(prison)
      @adult_age = prison.adult_age
      @max_visitors = prison.max_visitors
    end

    attr_reader :adult_age, :max_visitors
  end
end
