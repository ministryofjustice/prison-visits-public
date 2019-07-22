class BookingRequestsController < ApplicationController
  helper FormElementsHelper

  def index
    @steps = processor.steps
    @step_name = processor.step_name

    instrument_booking_request(step_name: @step_name)

    respond_to do |format|
      format.html do render processor.step_name end

      # Temporarily display flash notice ahead of PVB migration 25/7/19;
      # it will be removed once the migration complete
      flash[:notice] = t('.service_update')
    end
  end

  def create
    @steps = processor.steps

    if prison_unavailable?
      render :prison_unavailable
    else
      @visit = processor.execute!

      @step_name = processor.step_name

      instrument_booking_request(step_name: @step_name, visit: @visit)

      respond_to_request(@visit, @step_name)
    end
  end

private

  def prison_unavailable?
    return false unless processor.prison

    !processor.prison.enabled?
  end

  def respond_to_request(visit, step_name)
    respond_to do |format|
      format.html do
        if step_name == :completed
          redirect_to visit_path(visit.human_id, locale: I18n.locale)
        else
          render step_name
        end
      end
    end
  end

  def processor
    @processor ||= StepsProcessor.new(sanitised_steps_params.to_h, I18n.locale)
  end

  def instrument_booking_request(step_name:, visit: nil)
    PVB::Instrumentation.append_to_log booking_step_rendered: step_name
    PVB::Instrumentation.append_to_log visit_id: visit.id if visit
  end

  def sanitised_steps_params
    params.permit(
      :review_step,
      prisoner_step: permitted_prisoner_params,
      visitors_step: permitted_visitors_params,
      slots_step: permitted_slots_params,
      confirmation_step: [:confirmed]
    )
  end

  def permitted_slots_params
    %i[option_0 option_1 option_2 currently_filling review_slot skip_remaining_slots]
  end

  def permitted_prisoner_params
    [
      :first_name,
      :last_name,
      :number,
      :prison_id,
      date_of_birth: %i[day month year]
    ]
  end

  def permitted_visitors_params
    [
      :email_address,
      :email_address_confirmation,
      :phone_no,
      :additional_visitor_count,
      visitors_attributes: [
        :first_name,
        :last_name,
        date_of_birth: %i[day month year]
      ]
    ]
  end

  def prison
    @steps.fetch(:prisoner_step).prison
  end

  helper_method :prison

  def reviewing?
    params.key?(:review_step)
  end
  helper_method :reviewing?
end
