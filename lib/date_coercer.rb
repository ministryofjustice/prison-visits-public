# Coerces date input into either a Date (if the date is valid)
module DateCoercer
  def self.coerce(value)
    if value.nil?
      nil
    elsif value.respond_to?(:values_at)
      ymd = value.values_at(:year, :month, :day)
      rescue_invalid_date { Date.new(*ymd.map(&:to_i)) }
    end
  end

  def self.rescue_invalid_date
    yield
  rescue ArgumentError # e.g. invalid date such as 2010-14-31
    nil
  end
end
