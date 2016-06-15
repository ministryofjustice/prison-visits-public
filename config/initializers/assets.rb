Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[
  email.css
  *.png
  favicon.ico
  application-ie8.css
]

Rails.application.config.assets.paths <<
  "#{Rails.root}/vendor/assets/moj.slot-picker/dist/stylesheets"
