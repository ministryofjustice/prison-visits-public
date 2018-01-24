class VisitorListType < ActiveModel::Type::Value
  def cast(value)
    visitors = value.map { |visitor| Visitor.new(visitor) }

    VisitorList.new(visitors)
  end
end
