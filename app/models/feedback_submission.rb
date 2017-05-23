require 'maybe_date'

class FeedbackSubmission
  include NonPersistedModel
  include Dob

  attribute :body, String
  attribute :prisoner_number, String
  attribute :date_of_birth, MaybeDate
  attribute :prison_id, Integer
  attribute :email_address, String
  attribute :referrer, String
  attribute :user_agent, String

  validates :body, presence: true
  validate :email_format

  validates :prisoner_number, allow_blank: true, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }

  def email_address=(val)
    stripped = val.try(:strip)
    super(stripped)
  end

private

  def email_format
    return if email_address.blank?

    email_checker = EmailChecker.new(email_address)

    unless email_checker.valid?
      errors.add(:email_address, 'has incorrect format')
    end
  end
end
