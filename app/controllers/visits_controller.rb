class VisitsController < ApplicationController
  def show
    @visit = Rails.configuration.pvb_api.get_visit(params[:id])
  end
end
