class StepsProcessor
  def initialize(params, locale)
    @params = params
    @steps = load_steps
    @locale = locale
  end

  def template_name
    review_step_name || incomplete_step_name || :completed
  end

  def execute!
    return if incomplete?
    BookingRequestCreator.new.create!(
      steps.fetch(:prisoner_step),
      steps.fetch(:visitors_step),
      steps.fetch(:slots_step),
      @locale
    )
  end

  attr_reader :steps

private

  attr_reader :params

  def review_step_name
    steps.keys.find { |name| name.to_s == params[:review_step].to_s }
  end

  def incomplete_step_name
    steps.keys.find { |name| incomplete_step?(name) }
  end

  alias_method :incomplete?, :incomplete_step_name

  def load_steps
    {
      prisoner_step: load_step(PrisonerStep),
      visitors_step: load_step(VisitorsStep),
      slots_step: load_step(SlotsStep),
      confirmation_step: load_step(ConfirmationStep)
    }
  end

  def load_step(step_klass)
    step_name = step_klass.name.underscore
    step_params = params.fetch(step_name, {})
    step_klass.new(step_params.merge(prison_id: prison_id))
  end

  def incomplete_step?(name)
    params.key?(name) ? steps[name].invalid? : true
  end

  def prison_id
    params.fetch(:prisoner_step, {}).fetch(:prison_id, nil)
  end
end
