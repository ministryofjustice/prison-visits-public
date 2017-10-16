Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.active_support.deprecation = :log
  config.assets.debug = true
  config.assets.digest = true
  config.assets.raise_runtime_errors = true

  config.i18n.load_path =
    Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
  config.staff_url = 'http://localhost:3000'

  EmailAddressValidation.configure do |config|
    config.mx_checker = MxChecker::Dummy.new
  end
end
