class PrisonerStep
  include NonPersistedModel
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

  # rubocop:disable Metrics/AbcSize
  def validate_prisoner
    # If date_of_birth of number are invalid, there's no need to call the API
    return if errors[:date_of_birth].any? || errors[:number].any?

    result = PrisonVisits::Api.instance.validate_prisoner(
      number: number,
      date_of_birth: date_of_birth.to_date
    )

    return if result.fetch('valid')

    error_nomatch = 'prisoner_does_not_exist'
    if result.fetch('errors').include?(error_nomatch)
      errors.add :number, I18n.t(error_nomatch, scope: I18N_SCOPE)
      errors.add :date_of_birth, I18n.t(error_nomatch, scope: I18N_SCOPE)
    end
  rescue PrisonVisits::APIError => e
    Rails.logger.error e.message
  end
  # rubocop:enable Metrics/AbcSize
end
