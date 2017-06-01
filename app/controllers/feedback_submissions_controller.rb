class FeedbackSubmissionsController < ApplicationController
  def new
    @feedback = FeedbackSubmission.new(referrer: http_referrer)
  end

  def create
    @feedback = FeedbackSubmission.new(feedback_params)

    if @feedback.valid?
      PrisonVisits::Api.instance.create_feedback(@feedback)
      render :create
    else
      render :new
    end
  end

private

  def feedback_params
    params.
      require(:feedback_submission).
      permit(
        :referrer,
        :body,
        :prisoner_number,
        :prison_id,
        :email_address,
        date_of_birth: %i[day month year]
      ).
      merge(user_agent: http_user_agent)
  end
end
