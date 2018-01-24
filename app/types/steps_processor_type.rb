class StepsProcessorType < ActiveModel::Type::Value
  def cast(val)
    if val.is_a?(StepsProcessor)
      val
    else
      raise ArgumentError
    end
  end
end
