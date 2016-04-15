class Metrics
  class << self
    def log(category, message)
      fail 'Block required' unless block_given?

      started_at = Time.now.utc
      result = yield
      finished_at = Time.now.utc
      time_in_ms = (finished_at - started_at) * 1000

      Rails.logger.info "#{message} – %.2fms" % [time_in_ms]

      ## Add Request::Store totals by category, writes to log at the end of the request.

      result
    end
  end
end
