class BookingRequestsController < ApplicationController
  helper FormElementsHelper

  def index
    @steps = processor.steps
    @step_name = processor.step_name

    instrument_booking_request(step_name: @step_name)

    respond_to do |format|
      format.html { render processor.step_name }
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
    @processor ||= StepsProcessor.new(params, I18n.locale)
  end

  def instrument_booking_request(step_name:, visit: nil)
    PVB::Instrumentation.append_to_log booking_step_rendered: step_name
    PVB::Instrumentation.append_to_log visit_id: visit.id if visit
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
