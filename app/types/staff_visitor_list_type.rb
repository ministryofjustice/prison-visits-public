class StaffVisitorListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |visitor| VisitorType.new.cast(visitor) }.freeze
  end
end
