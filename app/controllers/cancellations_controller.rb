class CancellationsController < ApplicationController
  def create
    visit = Rails.configuration.pvb_api.cancel_visit(params[:id])
    redirect_to visit_path(visit.id)
  end

private

  def cancellation_confirmed?
    params[:confirmed].present?
  end
end
