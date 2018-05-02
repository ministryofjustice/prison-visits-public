require 'email_address_validation'

class FeedbackSubmission
  include MemoryModel

  attribute :body, :string
  attribute :prisoner_number, :string
  attribute :prisoner_date_of_birth, :uncoerced_date
  attribute :prison_id, :string
  attribute :email_address, :string
  attribute :referrer, :string
  attribute :user_agent, :string

  validates :body, presence: true
  validates :prisoner_date_of_birth, allow_blank: true, age: true
  validates :prisoner_number, allow_blank: true, prisoner_number: true
  validate :email_format

  def email_address=(val)
    stripped = val.try(:strip)
    super(stripped)
  end

private

  def email_format
    return if email_address.blank?

    email_checker = EmailAddressValidation::Checker.new(email_address)

    unless email_checker.valid?
      errors.add(:email_address, 'has incorrect format')
    end
  end
end
