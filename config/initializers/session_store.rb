# Be sure to restart your server when you modify this file.

config = {
  key: '_pvb2_session',
  secure: Rails.env.production?,
  httponly: true
}

if ENV.key?('HEROKU_APP_NAME')
  config[:domain] = "#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
end

Rails.application.config.session_store :cookie_store, config

