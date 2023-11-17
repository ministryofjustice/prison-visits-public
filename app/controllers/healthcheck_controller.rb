class HealthcheckController < ApplicationController
  def index
    healthcheck = Healthcheck::PvbApiCheck.new('PVB API healthcheck')
    status = healthcheck.ok? ? :ok : :bad_gateway

    render status:, json: {
      ok: healthcheck.ok?,
      api: healthcheck.report
    }
  end
end
