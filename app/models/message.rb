class Message < Staff::ApplicationRecord
  belongs_to :user

  with_options optional: true do
    belongs_to :visit, class_name: 'Staff::Visit'
    belongs_to :visit_state_change
  end

  validates :body, presence: true
  validates :user_id, presence: true

  def self.create_and_send_email(attrs)
    message = new(attrs)
    template_id = '4a7dfdc2-6fc6-4ccc-98ac-a86d9ebb6133'

    visit = Staff::Visit.find(message.visit_id)

    @gov_notify_email = GovNotifyEmailer.new
    @gov_notify_email.send_email(visit, template_id, nil, message) if message.save

    message
  end
end
