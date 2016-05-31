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

    def validate_visitor_ages_on(target, field, ages)
      # The person requesting the visit (the lead visitor) must be over 18, and
      # corresponds to the first visitor entered.
      # Note that this is not related to the 'adult' age which varies by prison.
      adults, _children = ages.partition { |a| adult?(a) }.map(&:length)
      if adults > MAX_ADULTS
        target.errors.add field, :too_many_adults,
          max: MAX_ADULTS,
          age: adult_age
      end
    end

    def validate_visitor_number(target, field, number)
      if number > max_visitors
        target.errors.add field, :too_many_visitors, max: max_visitors
      end
    end

  private

    def adult?(age)
      age >= adult_age
    end
  end

  class SlotConstraints
    delegate :map, to: :@slots

    def initialize(slots)
      @slots = slots
    end

    def bookable_date?(requested_date)
      @slots.any? { |s| s.to_date == requested_date }
    end

    def last_bookable_date
      @slots.sort.last.to_date
    end

    def bookable_slots?
      @slots.any?
    end
  end
end
