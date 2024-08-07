class HealthController < ApplicationController
  def index
    nomis_health = Healthcheck::NomisApiCheck.new('Nomis API healthcheck')
    vsip_health = Healthcheck::VsipApiCheck.new('Vsip API healthcheck')

    render status:, json: {
      status: nomis_health.ok? && vsip_health.ok? ? :UP : :DOWN,
      components: {
        nomis: {
          status: nomis_health.ok? ? :UP : :DOWN,
          detail: nomis_health.ok? ? :UP : nomis_health.report[:error]
        },
        vsip: {
          status: vsip_health.ok? ? :UP : :DOWN,
          detail: vsip_health.ok? ? :UP : vsip_health.report[:error]
        }
      },
      uptime: Time.zone.now - Rails.configuration.booted_at,
      build: {
        buildNumber: ENV['BUILD_NUMBER'],
        gitRef: ENV['GIT_REF']
      },
      version: ENV['BUILD_NUMBER']
    }
  end
end
