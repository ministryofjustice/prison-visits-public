require 'maybe_date'

class VisitorsStep
  include NonPersistedModel

  MAX_ADULTS = 3
  LEAD_VISITOR_MIN_AGE = 18

  class Visitor
    include NonPersistedModel
    include Person

    attribute :first_name, String
    attribute :last_name, String
    attribute :date_of_birth, MaybeDate
  end

  attribute :processor, StepsProcessor

  attribute :email_address, String
  attribute :phone_no, String
  attribute :visitors, Array[Visitor]

  delegate :max_visitors, :adult_age, to: :visitor_constraints

  validates :email_address, presence: true
  validates :phone_no, presence: true, length: { minimum: 9 }

  validate :validate_email, :validate_visitors

  attr_reader :general # Required in order to assign errors to 'general'

  def email_address=(val)
    super(val.strip)
  end

  # Return at least Prison::MAX_VISITORS visitors, filling with new instances
  # as needed. The regular #visitors method will return only those visitors
  # actually supplied via filled fields (or one blank primary visitor).
  def backfilled_visitors
    existing = visitors
    num_needed = max_visitors - existing.count
    backfill = num_needed.times.map { Visitor.new }
    existing + backfill
  end

  def visitors_attributes=(params)
    # params is of the form
    # {"0" => {"foo" => "bar"}, "1" => {"foo" => "baz"}}
    # so we sort by key and take the values. We throw away empty visitors.
    pruned = ParameterPruner.new.prune(
      params.sort_by { |k, _| k.to_i }.map(&:last)
    )

    # We always want at least one visitor. Leaving the rest blank is fine, but
    # the first one must both exist and be valid.
    self.visitors = pruned.empty? ? [{}] : pruned
  end

  def valid?(*)
    # The step validation must be called after the individual visitor
    # validations, since it adds additional errors onto the visitors, which
    # would be clobbered by calling visitor.valid?
    visitors_valid = visitors.map(&:valid?).all?
    step_valid = super

    visitors_valid && step_valid
  end

  alias_method :validate, :valid?

  def additional_visitor_count
    visitors.count - 1
  end

  def visitor_constraints
    @visitor_constraints ||=
      processor.booking_constraints.on_visitors
  end

private

  def validate_email
    checker = EmailChecker.new(email_address)
    unless checker.valid?
      errors.add :email_address, checker.message
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def validate_visitors
    # It's invalid if there are no visitors, but there's no need to call the API
    if visitors.empty?
      errors.add :general, :too_few_visitors
      return
    end

    result = PrisonVisits::Api.instance.validate_visitors(
      prison_id: processor.prison.id,
      lead_date_of_birth: lead_visitor.date_of_birth,
      dates_of_birth: visitors.map(&:date_of_birth)
    )

    return if result.fetch('valid')

    if result.fetch('errors').include?('too_many_visitors')
      errors.add :general, :too_many_visitors, max: max_visitors
    end

    if result.fetch('errors').include?('too_many_adults')
      errors.add :general, :too_many_adults,
        max: MAX_ADULTS,
        age: adult_age
    end

    if result.fetch('errors').include?('lead_visitor_age')
      lead_visitor.errors.add :date_of_birth, :lead_visitor_age,
        min: LEAD_VISITOR_MIN_AGE
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def lead_visitor
    visitors.first
  end
end
