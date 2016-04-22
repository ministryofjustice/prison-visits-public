class FeedbackSubmission
  include NonPersistedModel

  attribute :body, String
  attribute :email_address, String
  attribute :referrer, String
  attribute :user_agent, String

  validates :body, presence: true
  validate :email_format

  def email_address=(val)
    stripped = val.try(:strip)
    super(stripped)
  end

private

  def email_format
    return if email_address.blank?

    # true overrides sendgrid validations
    email_checker = EmailChecker.new(email_address, true)

    unless email_checker.valid?
      errors.add(:email_address, 'has incorrect format')
    end
  end
end
