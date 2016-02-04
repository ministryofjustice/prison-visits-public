require 'excon'

class PrisonVisitsAPI
  def initialize(host)
    @host = host
    @connection = Excon.new(host, persistent: true)
  end

  def get(route, params = {})
    options = {
      path: "/api/#{route}.json",
      expects: [200],
      headers: {
        'Accept' => 'application/json',
        'Accept-Language' => 'en'
      },
      query: params
    }
    response = @connection.get(options)
    JSON.parse(response.body)
  end
end
