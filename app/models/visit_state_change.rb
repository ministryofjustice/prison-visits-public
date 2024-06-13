class VisitStateChange < Staff::ApplicationRecord
  belongs_to :visit, class_name: 'Staff::Visit'

  with_options optional: true do
    belongs_to :visitor
    belongs_to :processed_by, class_name: 'User'
    belongs_to :creator, polymorphic: true
  end

  scope :booked,    -> { where(visit_state: 'booked') }
  scope :rejected,  -> { where(visit_state: 'rejected') }
  scope :withdrawn, -> { where(visit_state: 'withdrawn') }
  scope :cancelled, -> { where(visit_state: 'cancelled') }
end
