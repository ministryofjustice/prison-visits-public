class VisitorListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |visitor| Visitor.new(visitor) }.freeze
  end
end
