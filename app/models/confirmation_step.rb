class ConfirmationStep
  include MemoryModel

  attribute :processor, :steps_processor
  attribute :confirmed, :boolean
  validates :confirmed, inclusion: { in: [true] }

  def options_available?
    false
  end
end
