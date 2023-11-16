Rails.application.config.to_prepare do
  ActiveModel::Type.register(:concrete_slot, ConcreteSlotType)
  ActiveModel::Type.register(:concrete_slot_list, ConcreteSlotListType)
  ActiveModel::Type.register(:steps_processor, StepsProcessorType)
  ActiveModel::Type.register(:uncoerced_date, UncoercedDateType)
  ActiveModel::Type.register(:visitor_list, VisitorListType)
end
