class Staff::Visitor < Staff::ApplicationRecord
  include Staff::Person

  belongs_to :visit, class_name: 'Staff::Visit'

  validates :visit, :sort_index, presence: true

  default_scope do
    order(sort_index: :asc)
  end

  scope :banned,   -> { where(banned: true) }
  scope :unlisted, -> { where(not_on_list: true) }
  scope :allowed,  -> { where(banned: false, not_on_list: false) }

  def allowed?
    !(banned || not_on_list || other_rejection_reason)
  end

  def status
    return 'banned' if banned?
    return 'not on list' if not_on_list?

    'allowed'
  end
end
