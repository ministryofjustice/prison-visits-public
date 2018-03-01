Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[
  email.css
  *.png
  *.svg
  favicon.ico
  application-ie8.css
  gov.uk_logotype_crown.svg
  application_ie.js
  jasmine-jquery.js
]

Rails.application.config.assets.paths <<
  "#{Rails.root}/vendor/assets/moj.slot-picker/dist/stylesheets"
