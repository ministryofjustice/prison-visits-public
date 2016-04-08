require 'excon'

module PrisonVisits
  class Client
    TIMEOUT = 2 # seconds

    def initialize(host)
      @host = host
      @connection = Excon.new(
        host,
        persistent: true,
        connect_timeout: TIMEOUT,
        read_timeout: TIMEOUT,
        write_timeout: TIMEOUT)
    end

    def get(route, params = {})
      request(:get, route, params)
    end

    def post(route, params)
      request(:post, route, params)
    end

    def delete(route, params = {})
      request(:delete, route, params)
    end

  private

    # rubocop:disable Metrics/MethodLength
    def request(method, route, params)
      # For cleanliness, strip initial / if supplied
      route = route.sub(%r{^\/}, '')
      path = "/api/#{route}.json"

      options = {
        method: method,
        path: path,
        expects: [200],
        headers: {
          'Accept' => 'application/json',
          'Accept-Language' => I18n.locale
        }
      }.deep_merge(params_options(method, params))

      Rails.logger.info do
        "Calling PVB API: #{method.to_s.upcase} #{path}"
      end

      response = @connection.request(options)

      JSON.parse(response.body)
    end
    # rubocop:enable Metrics/MethodLength

    # Returns excon options which put params in either the query string or body.
    def params_options(method, params)
      return {} if params.empty?

      if method == :get || method == :delete
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
