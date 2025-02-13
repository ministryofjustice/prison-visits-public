Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.serve_static_files   = true
  config.static_cache_control = 'public, max-age=3600'
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_controller.allow_forgery_protection = false
  config.action_dispatch.show_exceptions = :none
  config.active_support.test_order = :random
  config.active_support.deprecation = :stderr
  config.assets.precompile += %w[jasmine-jquery.js]

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
  config.staff_url = 'http://localhost:3000'

  EmailAddressValidation.configure do |config|
    config.mx_checker = MxChecker::Dummy.new
  end

  config.sentry_dsn = ''
end
