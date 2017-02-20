class SlotsStep
  include NonPersistedModel

  attr_accessor :review_slot, :currently_filling, :skip_remaining_slots

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
      record.errors.add(attr, 'is not a parseable slot')
    end

    if slot && !record.slot_constraints.bookable_slot?(slot)
      record.errors.add(attr, 'is not a bookable slot')
    end
  end
  # rubocop:enable Style/BracesAroundHashParameters

  validates :option_0, presence: true

  delegate :bookable_slots?, to: :slot_constraints

  def options_available?
    if skip_remaining_slots || just_reviewed_slot? ||
       currently_filling_slot_left_blank?
      false
    else
      next_slot_to_fill ? true : false
    end
  end

  def just_reviewed_slot?
    review_slot.present? && currently_filling.present? &&
      review_slot == currently_filling
  end

  def currently_filling_slot_left_blank?
    currently_filling.present? && send("option_#{currently_filling}").blank?
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

  def next_slot_to_fill
    return review_slot if review_slot.present?
    return '0' if option_0.blank?
    return '1' if option_1.blank?
    return '2' if option_2.blank?
  end
end
