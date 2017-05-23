module Person
  extend ActiveSupport::Concern

  included do
    validates :first_name, presence: true, name: true
    validates :last_name, presence: true, name: true
    validates :date_of_birth,
      presence: true,
      inclusion: {
        in: ->(p) { p.minimum_date_of_birth..p.maximum_date_of_birth }
      }
  end

  def full_name
    I18n.t('formats.name.full', first: first_name, last: last_name)
  end

  def anonymized_name
    I18n.t('formats.name.full', first: first_name, last: last_name[0])
  end

  def minimum_date_of_birth
    Dob::MAX_AGE.years.ago.beginning_of_year.to_date
  end

  def maximum_date_of_birth
    Time.zone.today.end_of_year
  end
end
