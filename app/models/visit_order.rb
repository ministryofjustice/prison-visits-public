# :nocov:
# TODO: Remove
class VisitOrder < Staff::ApplicationRecord
  belongs_to :visit, class_name: 'Staff::Visit'
end
