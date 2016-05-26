class SlotsStep
  include NonPersistedModel

  attribute :processor, StepsProcessor

  attribute :option_0, String
  attribute :option_1, String
  attribute :option_2, String

  # rubocop:disable Style/BracesAroundHashParameters
  # (you're wrong rubocop, it's a syntax error if omitted)
  validates_each :option_0, :option_1, :option_2, {
    allow_blank: true
  } do |record, attr, value|
    begin
      slot = ConcreteSlot.parse(value) # rescue ArgumentError false
    rescue ArgumentError
      record.errors.add(attr, 'must start with upper case')
    end

    if slot && !record.slot_constraints.bookable_slot?(slot)
      record.errors.add(attr, 'is not a bookable slot')
    end
  end
  # rubocop:enable Style/BracesAroundHashParameters

  validates :option_0, presence: true

  delegate :bookable_slots?, to: :slot_constraints

  def options_available?
    options.length < 3
  end

  def additional_options?
    options.length > 1
  end

  def slots
    options.map { |s| ConcreteSlot.parse(s) }
  end

  def options
    [option_0, option_1, option_2].select(&:present?)
  end

  def slot_constraints
    # Temporary Easter egg to switch on live slot availability :)
    show_live_slots = processor.prisoner_step.first_name == 'Rickie'

    @constraints ||= processor.booking_constraints.on_slots(show_live_slots)
  end
end
