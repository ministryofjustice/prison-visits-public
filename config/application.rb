require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require_relative '../app/middleware/http_method_not_allowed'

Bundler.require(*Rails.groups)

module PrisonVisits
  class Application < Rails::Application
    config.phase = 'live'
    config.product_type = 'service'

    config.autoload_paths += %w[ app/mailers/concerns ]

    config.i18n.load_path =
      Dir[Rails.root.join('config', 'locales', '{en,cy}', '*.yml').to_s]

    config.i18n.default_locale = :en

    config.time_zone = 'London'

    # The last 3 errors can be removed with Rails 5. See Rails PR #19632
    config.action_dispatch.rescue_responses.merge!(
      'StateMachines::InvalidTransition' => :unprocessable_entity,
      'ActionController::ParameterMissing' => :bad_request,
      'Rack::Utils::ParameterTypeError' => :bad_request,
      'Rack::Utils::InvalidParameterError' => :bad_request
    )

    config.ga_id = ENV['GA_TRACKING_ID']

    config.smoke_test =
      OpenStruct.new(
        local_part:
          Regexp.escape(
            ENV.fetch('SMOKE_TEST_EMAIL_LOCAL_PART', 'prison-visits-smoke-test')
          ),
        domain:
          Regexp.escape(
            ENV.fetch('SMOKE_TEST_EMAIL_DOMAIN', 'digital.justice.gov.uk')
          )
      )

    config.exceptions_app = ->(env) { ErrorHandler.call(env) }

    if ENV['ASSET_HOST']
      config.asset_host = ENV['ASSET_HOST']
    end

    config.api_host = ENV.fetch('PRISON_VISITS_API', 'http://localhost:3000/')

    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      event.payload[:custom_log_items]
    end

    config.email_domain = ENV.fetch('EMAIL_DOMAIN', 'localhost')

    config.middleware.insert_before ActionDispatch::ParamsParser,
      HttpMethodNotAllowed
  end
end
