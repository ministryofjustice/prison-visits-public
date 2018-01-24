class ConcreteSlotListType < ActiveModel::Type::Value
  def cast(value)
    slots = value.map { |slot| ConcreteSlot.parse(slot) }

    ConcreteSlotList.new(slots)
  end
end
