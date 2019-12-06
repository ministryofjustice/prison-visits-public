class UncoercedDate
  attr_reader :year, :month, :day

  def initialize(year, month, day)
    self.year = year
    self.month = month
    self.day = day
    self.casted_to_date = false
    self.date = nil
  end

  def to_date
    return date if date || casted_to_date

    self.casted_to_date = true
    self.date = Date.new(year, month, day)
  rescue ArgumentError
    # Do nothing
  end

  def ==(other)
    self.class == other.class &&
      year == other.year &&
      month == other.month &&
      day == other.day
  end

private

  attr_writer :year, :month, :day
  attr_accessor :date, :casted_to_date
end
