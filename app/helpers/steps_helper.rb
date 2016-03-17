module StepsHelper
  def additional_visitor_selections(step)
    step.max_visitors.times.map do |n|
      [n.to_s, n]
    end
  end
end
