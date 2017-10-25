module Healthcheck
  class PvbApiCheck
    include CheckComponent

    def initialize(description)
      build_report(description) do
        { ok: healthy_pvb_connection }
      end
    end

  private

    def healthy_pvb_connection
      client.healthcheck.status == 200
    end

    def client
      PrisonVisits::Client.new(Rails.configuration.api_host, persistent: false)
    end
  end
end
