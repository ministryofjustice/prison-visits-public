class StepsProcessor
  STEP_NAMES = %i[ prisoner_step slots_step visitors_step confirmation_step ].
                 freeze

  delegate :prison, to: :prisoner_step

  def initialize(params, locale)
    @steps = load_steps(params)
    @locale = locale

    # Compute now to avoid keeping @params
    @steps_submitted = STEP_NAMES.select { |s| params.key?(s) }
    @review_step = STEP_NAMES.find { |s| s.to_s == params[:review_step].to_s }
  end

  def step_name
    @review_step || incomplete_step_name || :completed
  end

  def execute!
    return if incomplete_step_name
    BookingRequestCreator.new.create!(
      steps.fetch(:prisoner_step),
      steps.fetch(:visitors_step),
      steps.fetch(:slots_step),
      @locale
    )
  end

  attr_reader :steps

  def prisoner_step
    @steps[:prisoner_step]
  end

  def booking_constraints
    BookingConstraints.new(
      prison: prison,
      prisoner_number: prisoner_step.number,
      prisoner_dob: prisoner_step.date_of_birth
    )
  end

private

  def incomplete_step_name
    # Memoize this method, since otherwise potentially expensive step
    # validations are excecuted multiple times (for example the Visitor step
    # validation which calls the Sendgrid API)
    @_incomplete_step_name ||= STEP_NAMES.find { |name| incomplete_step?(name) }
  end

  def incomplete_step?(name)
    pp steps
    !@steps_submitted.include?(name) || steps[name].invalid? ||
      steps[name].options_available?
  end

  def load_steps(params)
    {
      prisoner_step: load_step(PrisonerStep, params),
      slots_step: load_step(SlotsStep, params),
      visitors_step: load_step(VisitorsStep, params),
      confirmation_step: load_step(ConfirmationStep, params)
    }
  end

  def load_step(step_klass, params)
    step_name = step_klass.name.underscore
    filtered_params = require_params_for_step(step_name, params) || {}
    step_klass.new(filtered_params.merge(processor: self))
  end

  def require_params_for_step(a_step, params)
    return {} if params.keys.empty?
    case [a_step, params[a_step].present?]
    when ['prisoner_step', true ]
      prisoner_step_params(params)
    when [ 'slots_step', true ]
      slots_step_params(params)
    when [ 'visitors_step', true ]
      visitor_step_params(params)
    when [ 'confirmation_step', true ]
      confirmation_step_params(params)
    end
  end

  def visitor_step_params(params)
    params.require(:visitors_step).permit(
      :processor,
      :email_address,
      :phone_no,
      visitors: [
        :first_name,
        :last_name,
        date_of_birth: [:day, :month, :year]
      ]
    )
  end

  def confirmation_step_params(params)
    params.require(:comfirmation_step).permit(confirmed: [])
  end

  def prisoner_step_params(params)
    params.require(:prisoner_step).permit(
      :processor,
      :first_name,
      :last_name,
      :number,
      :prison_id,
      date_of_birth: [:day, :month, :year]
    )
  end

  def slots_step_params(params)
    params.require(:slots_step).permit(
      :processor,
      :review_slot,
      :currently_filling,
      :skip_remaining_slots,
      :option_0,
      :option_1,
      :option_2
    )
  end
end
