require 'maybe_date'

class VisitorsStep
  include NonPersistedModel

  class Visitor
    include NonPersistedModel
    include Person

    attribute :first_name, String
    attribute :last_name, String
    attribute :date_of_birth, MaybeDate
    attribute :lead, Boolean, default: false

    validate :validate_lead_visitor_age, if: ->(v) { v.lead }

    def validate_lead_visitor_age
      if age < 18
        errors.add(:date_of_birth, min: 18)
      end
    end
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

    if pruned.any?
      pruned.first.merge!(lead: true)
    end

    # We always want at least one visitor. Leaving the rest blank is fine, but
    # the first one must both exist and be valid.
    self.visitors = pruned.empty? ? [{}] : pruned
  end

  def valid?(*)
    # This must be eager because we want to show errors on all objects.
    visitors.inject([super]) { |a, e| a << e.valid? }.all?
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

  def validate_visitors
    ages = visitors.map(&:age).compact
    visitor_constraints.validate_visitor_ages_on self, :general, ages
    visitor_constraints.validate_visitor_number self, :general, visitors.size
  end
end
