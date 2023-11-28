require File.expand_path('boot', __dir__)

require 'rails'
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require_relative '../app/middleware/http_method_not_allowed'
require_relative '../app/middleware/robots_tag'

# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_cable/engine"
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PrisonVisits
  class Application < Rails::Application
    config.load_defaults 6.1

    # Rails 7 new defaults
    config.active_support.cache_format_version = 7.0
    config.active_support.disable_to_s_conversion = true

    config.phase = 'live'
    config.product_type = 'service'

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
    config.sentry_dsn = ENV['SENTRY_DSN']
    config.sentry_js_dsn = ENV['SENTRY_JS_DSN']
    config.kubernetes_deployment = ENV['KUBERNETES_DEPLOYMENT']

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

    config.api_host = ENV.fetch('PRISON_VISITS_API', 'http://localhost:4000/')

    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      event.payload[:custom_log_items]
    end

    config.email_domain = ENV.fetch('EMAIL_DOMAIN', 'localhost')

    config.max_threads = ENV.fetch('RAILS_MAX_THREADS', 15)

    config.middleware.use RobotsTag
    config.middleware.insert_before Rack::Head, HttpMethodNotAllowed
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # We still use ie stylesheets as well as the govuk_template
    config.action_view.preload_links_header = false
  end
end
