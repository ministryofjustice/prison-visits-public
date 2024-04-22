class NomisConcreteSlot < Staff::ApplicationRecord
  belongs_to :prison, class_name: 'Staff::Prison', inverse_of: :nomis_concrete_slots
end
