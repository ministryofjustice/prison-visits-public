module PrisonVisits
  # (in the context of a HTTP API, get_prisons is not bad style)
  class Api
    include Singleton

    def initialize
      self.pool = ConnectionPool.new(pool_size: Rails.configuration.max_threads,
                                     timeout: 1) do
        PrisonVisits::Client.new(Rails.configuration.api_host)
      end
    end

    def get_prisons
      if Rails.configuration.use_staff_api
        result = pool.with { |client| client.get('/prisons') }
        result['prisons'].map { |params| Prison.new(params) }
      else
        Staff::Prison.order(name: :asc).all
      end
    end

    def get_prison(prison_id)
      if Rails.configuration.use_staff_api
        result = pool.with { |client| client.get("/prisons/#{prison_id}") }
        Prison.new(result['prison'])
      else
        Prison.new(Staff::Prison.find(prison_id).
          as_json.except('booking_window', 'slot_details', 'created_at', 'updated_at', 'lead_days',
                         'weekend_processing', 'estate_id', 'translations').
          merge({ max_visitors: Staff::Prison::MAX_VISITORS }))
      end
    end

    def validate_prisoner(number:, date_of_birth:)
      if Rails.configuration.use_staff_api
        result = pool.with { |client|
          client.post(
            '/validations/prisoner',
            params: {
              number:,
              date_of_birth:
            },
            idempotent: true
          )
        }
        result.fetch('validation')
      else
        Staff::PrisonerValidator.validate(number, date_of_birth)
      end
    end

    def validate_visitors(prison_id:, lead_date_of_birth:, dates_of_birth:)
      if Rails.configuration.use_staff_api
        result = pool.with { |client|
          client.post(
            '/validations/visitors',
            params: {
              prison_id:,
              lead_date_of_birth:,
              dates_of_birth:
            },
            idempotent: true
          )
        }
        result.fetch('validation')
      else
        Staff::VisitorsValidator.validate(prison_id, lead_date_of_birth, dates_of_birth)[:validation]
      end
    end

    def get_slots(prison_id:, prisoner_number:, prisoner_dob:)
      start_date = Time.zone.today.to_date
      end_date = 28.days.from_now.to_date
      if Rails.configuration.use_staff_api
        response = pool.with { |client|
          client.get(
            '/slots',
            params: {
              prison_id:,
              prisoner_number:,
              prisoner_dob:,
              start_date:,
              end_date:
            }
          )
        }
        response['slots'].map { |raw_slot| build_calendar_slot(raw_slot) }
      else
        Staff::Slots.slots(prison_id, prisoner_number, prisoner_dob, start_date, end_date).
          map { |raw_slot| build_calendar_slot(raw_slot) }
      end
    end

    def request_visit(params)
      if Rails.configuration.use_staff_api
        response = pool.with { |client| client.post('/visits', params:) }
        Visit.new(response.fetch('visit'))
      else
        visit_decorator(Staff::VisitsManager.new.create(params))
      end
    end

    def get_visit(id)
      if Rails.configuration.use_staff_api
        response = pool.with { |client| client.get("visits/#{id}") }
        Visit.new(response.fetch('visit'))
      else
        visit = Staff::Visit.where(human_id: id).first
        if visit
          visit_decorator(Staff::Visit.where(human_id: id).first)
        else
          return
        end
      end
    end

    def cancel_visit(id)
      if Rails.configuration.use_staff_api
        response = pool.with { |client| client.delete("visits/#{id}") }
        Visit.new(response.fetch('visit'))
      else
        visit_decorator(Staff::VisitsManager.new.destroy(id))
      end
    end

    def create_feedback(feedback_submission)
      params = {
        feedback: {
          body: feedback_submission.body,
          prisoner_number: feedback_submission.prisoner_number,
          prisoner_date_of_birth: feedback_submission.prisoner_date_of_birth&.to_date,
          prison_id: feedback_submission.prison_id,
          email_address: feedback_submission.email_address,
          referrer: feedback_submission.referrer,
          user_agent: feedback_submission.user_agent
        }
      }

      pool.with do |client| client.post('/feedback', params:) end
      nil
    end

  private

    def build_calendar_slot(raw_slot)
      CalendarSlot.new(slot: ConcreteSlot.parse(raw_slot.first),
                       unavailability_reasons: raw_slot.last)
    end

    def visit_decorator(visit)
      visitors = visit.visitors.map { |visitor|
        {
          anonymized_name: visitor.anonymized_name
        }
      }
      Visit.new(
        {
          id: visit.id,
          human_id: visit.human_id,
          processing_state: visit.processing_state,
          prison_id: visit.prison_id,
          confirm_by: visit.confirm_by,
          contact_email_address: visit.contact_email_address,
          slots: visit.slots.map(&:iso8601),
          slot_granted: visit.slot_granted&.iso8601,
          cancellation_reasons: visit.cancellation&.reasons,
          cancelled_at: visit.cancellation&.created_at&.iso8601,
          can_cancel: VisitorCancellationResponse.new(visit:).visitor_can_cancel?,
          can_withdraw: VisitorWithdrawalResponse.new(visit:).visitor_can_withdraw?,
          visitors:
        }
      )
    end

    attr_accessor :pool
  end
end
