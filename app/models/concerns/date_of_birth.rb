module DateOfBirth
  extend ActiveSupport::Concern

  MAX_AGE = 120

  included do
    validates :date_of_birth,
      allow_blank: true,
      inclusion: {
        in: ->(d) { d.minimum_date_of_birth..d.maximum_date_of_birth },
        message: I18n.t('concerns.date_of_birth.range', max: MAX_AGE)
      }
  end

  def minimum_date_of_birth
    MAX_AGE.years.ago.beginning_of_year.to_date
  end

  def maximum_date_of_birth
    Time.zone.today.end_of_year
  end
end
