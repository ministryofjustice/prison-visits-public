class ConcreteSlotList
  include Enumerable

  def initialize(concrete_slots = [])
    self.concrete_slots = concrete_slots.dup.freeze

    raise ArgumentError unless concrete_slots.all? { |v| v.is_a?(ConcreteSlot) }
  end

  def each(&block)
    concrete_slots.each(&block)
  end

private

  attr_accessor :concrete_slots
end
