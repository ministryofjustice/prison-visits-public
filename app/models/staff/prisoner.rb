class Staff::Prisoner < Staff::ApplicationRecord
  include Staff::Person

  attribute :number, :prisoner_number

  has_many :visits, class_name: 'Staff::Visit', dependent: :destroy
  validates :number, presence: true
end
