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
    @visit = processor.execute!
    @steps = processor.steps
    @step_name = processor.step_name

    instrument_booking_request(step_name: @step_name, visit: @visit)

    respond_to_request(@visit, @step_name)
  end

private

  def respond_to_request(visit, step_name)
    respond_to do |format|
      format.html do
        if step_name == :completed
          redirect_to visit_path(visit.id, locale: I18n.locale)
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
    Instrumentation.append_to_log booking_step_rendered: step_name
    Instrumentation.append_to_log visit_id: visit.id if visit
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
