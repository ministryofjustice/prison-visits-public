module Vsip
  class Api
    include Singleton
    BOOK_VISIT_TIMEOUT = 3
    def self.enabled?
      Rails.configuration.vsip_host != nil
    end

    def initialize
      unless self.class.enabled?
        fail Vsip::Error::Disabled, 'Vsip API is disabled'
      end

      pool_size = Rails.configuration.connection_pool_size
      @pool = ConnectionPool.new(size: pool_size, timeout: 5) do
        Vsip::Client.new(Rails.configuration.vsip_host)
      end
    end

    def supported_prisons
      response = @pool.with { |client|
        client.get('config/prisons/user-type/STAFF/supported')
      }

      mark_vsip_prisons response
    rescue Vsip::APIError => e
      PVB::ExceptionHandler.capture_exception(e, fingerprint: %w[vsip api_error])
    end

    def visit_sessions(nomis_id, prisoner_number)
      response = @pool.with { |client|
        client.get('visit-sessions/available', prisonId: nomis_id, prisonerId: prisoner_number.to_s.upcase,
                                               visitRestriction: 'OPEN')
      }
      slots = {}
      response.each do |session_json|
        session = OpenStruct.new(session_json)
        slots["#{Date.parse(session.sessionDate).strftime('%Y-%m-%d')}T" +
          Time.zone.parse(session.sessionTimeSlot['startTime']).strftime('%H:%M').to_s +
          Time.zone.parse(session.sessionTimeSlot['endTime']).strftime('/%H:%M').to_s
        ] = []
      end
      slots.merge({ vsip_api_failed: false })
    rescue APIError => _e
      { vsip_api_failed: true }
    end

  private

    def mark_vsip_prisons(prison_list)
      mark_all_estates_as_not_vsip
      prison_list.each do |prison_id|
        Estate.where(nomis_id: prison_id).update(vsip_supported: true)
      end
    end

    def mark_all_estates_as_not_vsip
      Estate.all.update(vsip_supported: false)
    end
  end
end
