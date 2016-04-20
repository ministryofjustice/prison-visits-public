class BookingRequestsController < ApplicationController
  helper FormElementsHelper

  def index
    processor = StepsProcessor.new(params, I18n.locale)
    @steps = processor.steps
    @step_name = processor.step_name
    Instrumentation.append_to_log booking_step_rendered: processor.step_name

    respond_to do |format|
      format.html { render processor.step_name }
    end
  end

  def create
    processor = StepsProcessor.new(params, I18n.locale)
    @visit = processor.execute!
    @steps = processor.steps
    @step_name = processor.step_name
    Instrumentation.append_to_log booking_step_rendered: processor.step_name
    Instrumentation.append_to_log visit_id: @visit.id if @visit

    respond_to do |format|
      format.html { render processor.step_name }
    end
  end

private

  def prison
    @steps.fetch(:prisoner_step).prison
  end
  helper_method :prison

  def reviewing?
    params.key?(:review_step)
  end
  helper_method :reviewing?
end
