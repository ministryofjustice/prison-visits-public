require 'excon'

module PrisonVisits
  APIError    = Class.new(StandardError)
  APINotFound = Class.new(StandardError)

  class Client
    TIMEOUT = 3 # seconds
    EXCON_INSTRUMENT_NAME = 'pvb_api'.freeze

    def initialize(host)
      @host = host
      @connection = Excon.new(
        host, persistent: true, connect_timeout: TIMEOUT,
              read_timeout: TIMEOUT, write_timeout: TIMEOUT, retry_limit: 3,
              instrumentor: ActiveSupport::Notifications,
              instrumentor_name: EXCON_INSTRUMENT_NAME
      )
    end

    def get(route, params: {}, idempotent: true)
      request(:get, route, params: params, idempotent: idempotent)
    end

    def post(route, params:, idempotent: false)
      request(:post, route, params: params, idempotent: idempotent)
    end

    def delete(route, params: {}, idempotent: true)
      request(:delete, route, params: params, idempotent: idempotent)
    end

    def healthcheck
      @connection.head(
        path: 'healthcheck',
        persistent: false
      )
    end

  private

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def request(method, route, params:, idempotent:)
      # For cleanliness, strip initial / if supplied
      route = route.sub(%r{^\/}, '')
      path = "/api/#{route}"
      api_method = "#{method.to_s.upcase} #{path}"

      options = {
        method: method,
        path: path,
        expects: [200],
        headers: {
          'Accept' => 'application/json',
          'Accept-Language' => I18n.locale,
          'X-Request-Id' => RequestStore.store[:request_id]
        },
        idempotent: idempotent
      }.deep_merge(params_options(method, params))

      response = @connection.request(options)
      JSON.parse(response.body)
    rescue Excon::Errors::NotFound
      raise APINotFound, api_method
    rescue Excon::Errors::HTTPStatusError => e
      body = e.response.body

      # API errors should be returned as JSON, but there are many scenarios
      # where this may not be the case.
      begin
        error = JSON.parse(body)
      rescue JSON::ParserError
        # Present non-JSON bodies truncated (e.g. this could be HTML)
        error = "(invalid-JSON) #{body[0, 80]}"
      end

      raise APIError,
        "Unexpected status #{e.response.status} calling #{api_method}: #{error}"
    rescue Excon::Errors::Error => e
      raise APIError, "Exception #{e.class} calling #{api_method}: #{e}"
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    # Returns excon options which put params in either the query string or body.
    def params_options(method, params)
      return {} if params.empty?

      if %i[get delete].include?(method)
        { query: params }
      else
        {
          body: params.to_json,
          headers: { 'Content-Type' => 'application/json' }
        }
      end
    end
  end
end
