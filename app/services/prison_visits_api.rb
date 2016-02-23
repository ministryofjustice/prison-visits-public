require 'excon'

class PrisonVisitsAPI
  def initialize(host)
    @host = host
    @connection = Excon.new(host, persistent: true)
  end

  def get(route, params = {})
    request(:get, route, params)
  end

  def post(route, params)
    options = {
      headers: { 'Content-Type' => 'application/json' }
    }
    request(:post, route, params, options)
  end

private

  # rubocop:disable Metrics/MethodLength
  def request(method, route, params, extra_options = {})
    # For cleanliness, strip initial / if supplied
    route = route.sub(%r{^\/}, '')
    path = "/api/#{route}.json"

    options = {
      method: method,
      path: path,
      expects: [200],
      headers: {
        'Accept' => 'application/json',
        'Accept-Language' => 'en'
      }
    }.merge(params_options(:get, params)).deep_merge(extra_options)

    response = @connection.request(options)

    JSON.parse(response.body)
  end
  # rubocop:enable Metrics/MethodLength

  def params_options(method, params)
    if method == :get
      { query: params }
    else
      b = params.respond_to?(:to_json) ? params.to_json : JSON.generate(params)
      { body: b }
    end
  end
end
