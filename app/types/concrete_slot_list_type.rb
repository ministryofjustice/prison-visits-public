class ConcreteSlotListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |slot| ConcreteSlot.parse(slot) }.freeze
  end
end
