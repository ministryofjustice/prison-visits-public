require 'maybe_date'

class PrisonerStep
  include NonPersistedModel
  include Person

  attribute :processor, StepsProcessor

  attribute :first_name, String
  attribute :last_name, String
  attribute :date_of_birth, MaybeDate
  attribute :number, String
  attribute :prison_id, Integer

  validates :number, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }
  validates :prison_id, presence: true

  validate :validate_prisoner

  delegate :name, to: :prison, prefix: true

  I18N_SCOPE = %i[ activemodel errors models prisoner_step api ]

  def prison
    # Memoize to avoid multiple API lookups
    @_prison ||= prison_id ? Prison.find_by_id(prison_id) : nil
  end

private

  def validate_prisoner
    result = PrisonVisits::Api.instance.validate_prisoner(
      number: number,
      date_of_birth: date_of_birth
    )

    return if result.fetch('valid')

    error_nomatch = 'prisoner_does_not_exist'
    if result.fetch('errors').include?(error_nomatch)
      errors.add :number, I18n.t(error_nomatch, scope: I18N_SCOPE)
      errors.add :date_of_birth, I18n.t(error_nomatch, scope: I18N_SCOPE)
    end
  end
end
