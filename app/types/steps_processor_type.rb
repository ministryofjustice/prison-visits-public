class StepsProcessorType < ActiveModel::Type::Value
  def cast(value)
    if value.is_a?(StepsProcessor)
      value
    else
      raise ArgumentError
    end
  end
end
