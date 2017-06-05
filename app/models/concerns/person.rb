module Person
  extend ActiveSupport::Concern

  included do
    validates :first_name, presence: true, name: true
    validates :last_name, presence: true, name: true
    validates :date_of_birth, presence: true, age: true
  end

  def full_name
    I18n.t('formats.name.full', first: first_name, last: last_name)
  end

  def anonymized_name
    I18n.t('formats.name.full', first: first_name, last: last_name[0])
  end
end
