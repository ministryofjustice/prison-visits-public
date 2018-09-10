class PrisonerStep
  include MemoryModel
  include Person

  attribute :processor, :steps_processor

  attribute :first_name, :string
  attribute :last_name, :string
  attribute :date_of_birth, :uncoerced_date
  attribute :number, :string
  attribute :prison_id, :string

  validates :number, prisoner_number: true
  validates :prison_id, presence: true

  validate :validate_prisoner

  delegate :name, to: :prison, prefix: true

  I18N_SCOPE = %i[ activemodel errors models prisoner_step api ]

  def prison
    # Memoize to avoid multiple API lookups
    @prison ||= prison_id.present? ? Prison.find_by_id(prison_id) : nil
  end

  def options_available?
    false
  end

  def prisoner_attributes
    {
      first_name: first_name,
      last_name: last_name,
      date_of_birth: date_of_birth.to_date,
      number: number
    }
  end

private

  def validate_prisoner
    return if prevent_api_call?
    return if prisoner_valid?

    describe_errors
  rescue PrisonVisits::APIError => e
    Rails.logger.error e.message
  end

  def prisoner_valid?
    prisoner_validation_results.fetch('valid')
  end

  def describe_errors
    error_nomatch = 'prisoner_does_not_exist'
    if prisoner_validation_results.fetch('errors').include?(error_nomatch)
      errors.add :number, I18n.t(error_nomatch, scope: I18N_SCOPE)
      errors.add :date_of_birth, I18n.t(error_nomatch, scope: I18N_SCOPE)
    end
  end

  def prisoner_validation_results
    options = { number: number, date_of_birth: date_of_birth.to_date }
    @prisoner_validation_results ||= PrisonVisits::Api.instance.validate_prisoner(options)
  end

  def prevent_api_call?
    # If date_of_birth of number are invalid, there's no need to call the API
    errors[:date_of_birth].any? || errors[:number].any?
  end
end
