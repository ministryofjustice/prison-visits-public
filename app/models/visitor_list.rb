class VisitorList
  include Enumerable

  def initialize(visitors = [])
    self.visitors = visitors.dup.freeze

    raise ArgumentError unless visitors.all? { |v| v.is_a?(Visitor) }
  end

  def each(&block)
    visitors.each(&block)
  end

  def to_a
    visitors.dup
  end

private

  attr_accessor :visitors
end
