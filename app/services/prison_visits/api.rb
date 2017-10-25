module PrisonVisits
  # (in the context of a HTTP API, get_prisons is not bad style)
  # rubocop:disable Naming/AccessorMethodName
  class Api
    include Singleton

    def initialize
      self.pool = ConnectionPool.new(pool_size: Rails.configuration.max_threads,
                                     timeout: 1) do
        PrisonVisits::Client.new(Rails.configuration.api_host)
      end
    end

    def get_prisons
      result = pool.with { |client| client.get('/prisons') }

      result['prisons'].map { |params| Prison.new(params) }
    end

    def get_prison(prison_id)
      result = pool.with { |client| client.get("/prisons/#{prison_id}") }

      Prison.new(result['prison'])
    end

    def validate_prisoner(number:, date_of_birth:)
      result = pool.with { |client|
        client.post(
          '/validations/prisoner',
          params: {
            number: number,
            date_of_birth: date_of_birth
          },
          idempotent: true
        )
      }
      result.fetch('validation')
    end

    def validate_visitors(prison_id:, lead_date_of_birth:, dates_of_birth:)
      result = pool.with { |client|
        client.post(
          '/validations/visitors',
          params: {
            prison_id: prison_id,
            lead_date_of_birth: lead_date_of_birth,
            dates_of_birth: dates_of_birth
          },
          idempotent: true
        )
      }

      result.fetch('validation')
    end

    def get_slots(prison_id:, prisoner_number:, prisoner_dob:)
      response = pool.with { |client|
        client.get(
          '/slots',
          params: {
            prison_id: prison_id, prisoner_number: prisoner_number,
            prisoner_dob: prisoner_dob,
            start_date: Time.zone.today.to_date, end_date: 28.days.from_now.to_date
          }
        )
      }
      response['slots'].map { |raw_slot| build_calendar_slot(raw_slot) }
    end

    def request_visit(params)
      response = pool.with { |client| client.post('/visits', params: params) }
      Visit.new(response.fetch('visit'))
    end

    def get_visit(id)
      response = pool.with { |client| client.get("visits/#{id}") }
      Visit.new(response.fetch('visit'))
    end

    def cancel_visit(id)
      response = pool.with { |client| client.delete("visits/#{id}") }
      Visit.new(response.fetch('visit'))
    end

    def create_feedback(feedback_submission)
      params = {
        feedback: {
          body: feedback_submission.body,
          prisoner_number: feedback_submission.prisoner_number,
          prisoner_date_of_birth: feedback_submission.prisoner_date_of_birth,
          prison_id: feedback_submission.prison_id,
          email_address: feedback_submission.email_address,
          referrer: feedback_submission.referrer,
          user_agent: feedback_submission.user_agent
        }
      }

      pool.with do |client| client.post('/feedback', params: params) end
      nil
    end

  private

    def build_calendar_slot(raw_slot)
      CalendarSlot.new(slot: ConcreteSlot.parse(raw_slot.first),
                       unavailability_reasons: raw_slot.last)
    end

    attr_accessor :pool
  end
  # rubocop:enable Naming/AccessorMethodName
end
