client = PrisonVisits::Client.new(Rails.configuration.api_host)
Rails.configuration.pvb_api = PrisonVisits::Api.new(client)
