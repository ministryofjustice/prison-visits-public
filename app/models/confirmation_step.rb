class ConfirmationStep
  include NonPersistedModel

  attribute :confirmed, Boolean
  validates :confirmed, inclusion: { in: [true] }

  def options_available?
    false
  end
end
