class SlotsStep
  include NonPersistedModel

  attribute :prison_id, Integer

  attribute :option_0, String
  attribute :option_1, String
  attribute :option_2, String

  # rubocop:disable Style/BracesAroundHashParameters
  # (you're wrong rubocop, it's a syntax error if omitted)
  validates_each :option_0, :option_1, :option_2, {
    allow_blank: true
  } do |record, attr, value|
    begin
      ConcreteSlot.parse(value) # rescue ArgumentError false
    rescue ArgumentError
      record.errors.add(attr, 'must start with upper case')
    end
  end
  # rubocop:enable Style/BracesAroundHashParameters

  validates :option_0, presence: true

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
    @constraints ||= BookingConstraints.new(prison_id: prison_id).on_slots
  end
end
