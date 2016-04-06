module PrisonVisits
  # rubocop:disable Style/AccessorMethodName
  # (in the context of a HTTP API, get_prisons is not bad style)
  class Api
    class << self
      def instance
        @instance ||= begin
          client = PrisonVisits::Client.new(Rails.configuration.api_host)
          new(client)
        end
      end
    end

    def initialize(api_client)
      @client = api_client
    end

    def get_prisons
      result = @client.get('/prisons')
      result['prisons'].map { |params| Prison.new(params) }
    end

    def get_prison(prison_id)
      result = @client.get("/prisons/#{prison_id}")
      Prison.new(result['prison'])
    end

    def validate_prisoner(number:, date_of_birth:)
      result = @client.post(
        '/validations/prisoner',
        number: number,
        date_of_birth: date_of_birth
      )
      result.fetch('validation')
    end

    def get_slots(prison_id:, prisoner_number:, prisoner_dob:)
      response = @client.get(
        '/slots',
        prison_id: prison_id,
        prisoner_number: prisoner_number,
        prisoner_dob: prisoner_dob
      )
      response['slots'].map { |s| ConcreteSlot.parse(s) }
    end

    def request_visit(params)
      response = @client.post('/visits', params)
      Visit.new(response.fetch('visit'))
    end

    def get_visit(id)
      response = @client.get("visits/#{id}")
      Visit.new(response.fetch('visit'))
    end

    def cancel_visit(id)
      response = @client.delete("visits/#{id}")
      Visit.new(response.fetch('visit'))
    end

    def create_feedback(params)
      @client.post('/feedback', params)
      nil
    end
  end
  # rubocop:enable Style/AccessorMethodName
end
