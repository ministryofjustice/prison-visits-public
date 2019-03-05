Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  # config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new

  config.force_ssl = true if ENV.key?('HEROKU_APP_NAME')

  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.logger = ActiveSupport::Logger.new \
    "#{Rails.root}/log/logstash_#{Rails.env}.json"

  config.staff_url = ENV.fetch('STAFF_SERVICE_URL')

  service_url = if ENV['HEROKU_APP_NAME']
                  URI.parse("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com")
                else
                  URI.parse(ENV.fetch('SERVICE_URL'))
                end

  config.action_controller.default_url_options = { host: service_url.hostname }
  # config.action_controller.asset_host = service_url.hostname

  config.kubernetes_deployment = ENV['KUBERNETES_DEPLOYMENT']

  EmailAddressValidation.configure do |config|
    config.mx_checker = MxChecker.new
  end
end
