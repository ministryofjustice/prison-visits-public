require 'sidekiq/api'

class Healthcheck
  def initialize
    @components = {
      database: DatabaseCheck.new('Postgres database'),
      zendesk: QueueCheck.new('Zendesk queue', queue_name: 'zendesk')
    }
  end

  def ok?
    @components.values.all?(&:ok?)
  end

  def checks
    @components.inject(ok: ok?) { |hash, (key, checker)|
      hash.merge(key => checker.report)
    }
  end
end
