require 'pvb/instrumentation'

PVB::Instrumentation.configure do |config|
  config.logger = Rails.logger
  config.register(
    "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.request",
    PVB::Instrumentation::Excon::Request
  )

  config.register(
    "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.retry",
    PVB::Instrumentation::Excon::Retry)

  config.register(
    "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.response",
    PVB::Instrumentation::Excon::Response)

  config.register(
    "#{PrisonVisits::Client::EXCON_INSTRUMENT_NAME}.error",
    PVB::Instrumentation::Excon::Error)

  config.register(
    'faraday.raven', PVB::Instrumentation::Faraday::Request)
end
