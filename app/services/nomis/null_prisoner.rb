module Nomis
  class NullPrisoner < Nomis::Prisoner
    attribute :api_call_successful, :boolean

    def iep_level; end

    def imprisonment_status; end

    def api_call_successful?
      api_call_successful
    end
  end
end
