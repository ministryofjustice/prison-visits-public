class VisitsController < ApplicationController
  def show
    @visit = PrisonVisits::Api.instance.get_visit(params[:id])
  end
end
