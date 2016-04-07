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

  def send_feedback
    PrisonVisits::Api.instance.create_feedback(feedback_params)
  end

private

  def email_format
    Mail::Address.new(email_address)
  rescue Mail::Field::ParseError
    errors.add(:email_address, 'has incorrect format')
  end

  def feedback_params
    {
      feedback: {
        body: body,
        email_address: email_address,
        referrer: referrer,
        user_agent: user_agent
      }
    }
  end
end
