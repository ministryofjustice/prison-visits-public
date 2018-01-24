class UncoercedDateType < ActiveModel::Type::Value
  def cast(value)
    if value.is_a?(Date)
      UncoercedDate.new(value.year, value.month, value.day)
    elsif value.respond_to?(:values_at)
      cast_with_values_at(value)
    end
  end

private

  def cast_with_values_at(value)
    ymd = value.values_at(:year, :month, :day).map(&:to_i)
    return nil if ymd == [0, 0, 0]

    UncoercedDate.new(*ymd)
  end
end
