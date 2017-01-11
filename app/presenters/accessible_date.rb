require_relative '../../lib/maybe_date'

class AccessibleDate
  include ActiveModel::Model

  attr_accessor :day, :month, :year

  validate :parsable?
  validates :year, :month, :day, { presence: true, if: :any_date_part? }

  def self.parse(date_or_hash)
    if date_or_hash.is_a?(Hash)
      new(date_or_hash)
    else
      new(
        day:   date_or_hash.day,
        month: date_or_hash.month,
        year:  date_or_hash.year
      )
    end
  end

  def attributes
    { day: day, month: month, year: year }
  end

private

  def any_date_part?
    attributes.values.any?(&:present?)
  end

  def parsable?
    return unless any_date_part?
    Date.new(*attributes.values_at(:year, :month, :day).map(&:to_i))
  rescue ArgumentError
    i18n_scope = [:activemodel, :errors, :messages]
    errors.add(:year,  I18n.t('invalid', scope: i18n_scope))
    errors.add(:month, I18n.t('invalid', scope: i18n_scope))
    errors.add(:day,   I18n.t('invalid', scope: i18n_scope))
  end
end
