class SlotsStep
  include MemoryModel

  attribute :processor, :steps_processor

  attribute :review_slot, :string
  attribute :currently_filling, :string
  attribute :skip_remaining_slots, :boolean
  attribute :option_0, :string
  attribute :option_1, :string
  attribute :option_2, :string

  before_validation :reorder_options

  validates_each :option_0, :option_1, :option_2,
    allow_blank: true do |record, attr, value|
    begin
      slot = ConcreteSlot.parse(value) # rescue ArgumentError false
    rescue ArgumentError
      record.errors.add(attr, 'is not a parseable slot')
    end

    if slot && !record.slot_constraints.bookable_slot?(slot)
      record.errors.add(attr, 'is not a bookable slot')
    end
  end

  validates :option_0, presence: true

  delegate :bookable_slots?, :unavailability_reasons, to: :slot_constraints

  def reorder_options
    if option_0.present? && option_1.blank? && option_2.present?
      self.option_1 = option_2
      self.option_2 = nil
    end
  end

  def skip_remaining_slots?
    errors.empty? && skip_remaining_slots == true
  end

  def options_available?
    if skip_remaining_slots? || just_reviewed_slot? ||
       currently_filling_slot_left_blank? || !available_bookable_slots?
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

  def slots
    options.map { |s| ConcreteSlot.parse(s) }
  end

  def valid_options
    %i[option_0 option_1 option_2].
      reject { |o| errors.keys.include?(o) }.
      map { |o| send(o) }.
      reject(&:blank?).
      map { |o| ConcreteSlot.parse(o) }
  end

  def options
    [option_0, option_1, option_2].select(&:present?)
  end

  def slot_constraints
    @slot_constraints ||= processor.booking_constraints.on_slots
  end

  def next_slot_to_fill
    return '0' if unbookable_slots_selected?
    return review_slot if review_slot.present?
    slots_select_count = valid_options.size
    return nil if slots_select_count == 3
    slots_select_count.to_s
  end

  def available_bookable_slots?
    return true if option_0.blank?

    slot_constraints.
      bookable_slots.
      map { |cs| cs.slot.iso8601 }.
      reject { |s| s.in?(options) }.
      any?
  end

  def unable_to_add_more_slots?
    !skip_remaining_slots && !available_bookable_slots?
  end

  def unbookable_slots_selected?
    options.map { |o| ConcreteSlot.parse(o) }.any? do |slot|
      !slot_constraints.bookable_slot?(slot)
    end
  end
end
