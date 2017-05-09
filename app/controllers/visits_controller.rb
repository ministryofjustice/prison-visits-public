class VisitsController < ApplicationController
  def show
    @visit = PrisonVisits::Api.instance.get_visit(params[:id])
    @request_completed = !request.referer.nil?
    render @visit.processing_state.to_s
  rescue PrisonVisits::APINotFound
    render 'errors/404', status: :not_found
  end
end
