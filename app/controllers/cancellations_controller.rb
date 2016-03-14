class CancellationsController < ApplicationController
  def create
    visit_id = params[:id]
    if cancellation_confirmed?
      Rails.configuration.pvb_api.cancel_visit(visit_id)
    end
    redirect_to visit_path(visit_id)
  end

private

  def cancellation_confirmed?
    params[:confirmed].present?
  end
end
