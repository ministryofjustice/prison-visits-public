class VisitsController < ApplicationController
  def show
    @visit = PrisonVisits::Api.instance.get_visit(params[:id])
    render @visit.processing_state.to_s
  end
end
