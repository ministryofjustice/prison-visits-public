class RobotsTag
  X_ROBOT_TAG_HEADER_VALUE = 'none'.freeze
  X_ROBOT_TAG_HEADER = 'X-Robots-Tag'.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env.dup)
    headers[X_ROBOT_TAG_HEADER] = X_ROBOT_TAG_HEADER_VALUE

    [status, headers, response]
  end
end
