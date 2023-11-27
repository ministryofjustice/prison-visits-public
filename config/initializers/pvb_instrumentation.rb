require 'pvb/instrumentation'
require 'pvp/instrumentation/mx_checker'

require_dependency '../services/prison_visits/client'

api_setup_proc = proc do |event|
  event.payload[:category] = :api
end

Rails.application.config.to_prepare do
  PVB::Instrumentation.configure do |config|
    config.logger = Rails.logger
    config.register(
      "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.request",
      PVB::Instrumentation::Excon::Request,
      api_setup_proc
    )

    config.register(
      "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.retry",
      PVB::Instrumentation::Excon::Retry,
      api_setup_proc
    )

    config.register(
      "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.response",
      PVB::Instrumentation::Excon::Response,
      api_setup_proc
    )

    config.register(
      "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.error",
      PVB::Instrumentation::Excon::Error,
      api_setup_proc
    )

    config.register(
      'faraday.raven', PVB::Instrumentation::Faraday::Request
    )

    config.register 'mx', PVP::Instrumentation::MxChecker
  end
end
