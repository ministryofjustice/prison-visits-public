module Healthcheck
  class PvbApiCheck
    include CheckComponent

    def initialize(description)
      build_report(description) do
        { ok: PrisonVisits::Api.instance.healthy? }
      end
    end
  end
end
