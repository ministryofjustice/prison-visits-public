UncoercedDate = Struct.new(:year, :month, :day)

# Coerces date input into either a Date (if the date is valid), or an
# UncoercedDate struct which can be redered back to the view for correction
class MaybeDate < Virtus::Attribute
  # This coercion is probably not as comprehensive as
  # Virtus::Attribute::Date, but it is understandable and sufficient for
  # our needs
  def coerce(value)
    return nil if value.nil?
    return value if value.is_a?(Date)

    if value.is_a?(String)
      Date.parse(value)
    elsif value.respond_to?(:values_at)
      coerce_with_values_at(value)
    end
  end

private

  def coerce_with_values_at(value)
    ymd = value.values_at(:year, :month, :day).map(&:to_i)
    return nil if ymd == [0, 0, 0]

    begin
      Date.new(*ymd)
    rescue ArgumentError # e.g. invalid date such as 2010-14-31
      UncoercedDate.new(*ymd)
    end
  end
end
