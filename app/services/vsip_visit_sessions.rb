class VsipVisitSessions
  def self.get_sessions(nomis_id, prisoner_number, advanceDays)
    @vsip_enabled_prisons = if Vsip::Api.enabled?
                              Vsip::Api.instance.visit_sessions(nomis_id, prisoner_number, advanceDays)
                            else
                              Vsip::NullSupportedPrisons.new(api_call_successful: false)
                            end
  end
end
