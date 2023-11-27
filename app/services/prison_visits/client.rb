require 'excon'

module PrisonVisits
  APIError    = Class.new(StandardError)
  APINotFound = Class.new(StandardError)

  # This client is **NOT** thread safe. To be used with a connection pool. See below.
  class Client
    TIMEOUT = 3 # seconds
    EXCON_INSTRUMENT_NAME = 'pvb_api'.freeze

    def initialize(host, persistent: true)
      @host = host

      # Sets `thread_safe_sockets` to `false` on the Excon connection. Setting
      # to `false` disables Excon connection sockets cache for each thread.
      #
      # This cache means that there is a socket connection for every Excon
      # connection object to the PVB API for each Thread. This is to make an
      # Excon connection thread safe.
      #
      # For example if Puma runs with 4 threads, and those threads reuse a
      # connection pool of 4 Excon connections means that effectevely there can
      # be up to 16 live connections to the PVB API.
      #
      # This cache is unnecessary in our case since:
      # - we ensure thread safety by using a connection pool
      # - we end up opening more sockets than necessary (16 vs 4). If we only
      #   have 4 puma threads we only need 4 sockets
      # - the cache has a memory leak when there are short lived threads.
      @connection = Excon.new(
        host, persistent:, connect_timeout: TIMEOUT,
              read_timeout: TIMEOUT, write_timeout: TIMEOUT, retry_limit: 3,
              thread_safe_sockets: false,
              instrumentor: ActiveSupport::Notifications,
              instrumentor_name: EXCON_INSTRUMENT_NAME
      )
    end

    def get(route, params: {}, idempotent: true)
      request(:get, route, params:, idempotent:)
    end

    def post(route, params:, idempotent: false)
      @first_time_try = true
      request(:post, route, params:, idempotent:)
    end

    def delete(route, params: {}, idempotent: true)
      request(:delete, route, params:, idempotent:)
    end

    def healthcheck
      @connection.head(path: 'healthcheck')
    end

  private

    def request(method, route, params:, idempotent:)
      path = "/api/#{sanitise_route(route)}"
      api_method = "#{method.to_s.upcase} #{path}"
      options = build_options(path, method, params, idempotent)
      response = @connection.request(options)

      JSON.parse(response.body)
    rescue Excon::Error::Socket => e
      try_resetting_connection(idempotent, api_method, e)
      retry
    rescue Excon::Errors::NotFound
      raise APINotFound, api_method
    rescue Excon::Errors::HTTPStatusError => e
      body = e.response.body

      # API errors should be returned as JSON, but there are many scenarios
      # where this may not be the case.
      error = describe_error(body)
      raise APIError,
            "Unexpected status #{e.response.status} calling #{api_method}: #{error}"
    rescue Excon::Errors::Error => e
      raise APIError, "Exception #{e.class} calling #{api_method}: #{e}"
    end

    def build_options(path, method, params, idempotent)
      {
        method:,
        path:,
        expects: [200],
        headers: {
          'Accept' => 'application/json',
          'Accept-Language' => I18n.locale,
          'X-Request-Id' => RequestStore.store[:request_id]
        },
        idempotent:
      }.deep_merge(params_options(method, params))
    end

    def try_resetting_connection(idempotent, api_method, error)
      if @first_time_try && !idempotent
        @first_time_try = false
        @connection.reset
      else
        raise APIError, "Exception #{error.class} calling #{api_method}: #{error}"
      end
    end

    def describe_error(body)
      JSON.parse(body)
    rescue JSON::ParserError
      # Present non-JSON bodies truncated (e.g. this could be HTML)
      "(invalid-JSON) #{body[0, 80]}"
    end

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

    def sanitise_route(route)
      uri_parts = route.split('/')
      uri_parts = uri_parts.map { |part| CGI.escape(part) }.join('/')
      strip_initial_forward_slash(uri_parts)
    end

    def strip_initial_forward_slash(path)
      path.sub(%r{^/}, '')
    end
  end
end
