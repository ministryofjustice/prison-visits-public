class FeedbackSubmissionsController < ApplicationController
  def new
    @feedback = FeedbackSubmission.new(referrer: http_referrer)
  end

  def create
    @feedback = FeedbackSubmission.new(feedback_params)

    if @feedback.save
      # TODO: Submit to API
    else
      render 'new'
    end
  end

private

  def feedback_params
    params.
      require(:feedback_submission).
      permit(:referrer, :body, :email_address).
      merge(user_agent: http_user_agent)
  end
end
