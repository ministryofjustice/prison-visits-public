# Be sure to restart your server when you modify this file.
#
Rails.application.config.session_store :cookie_store, expire_after: 30.minutes,
                                                      key: '_pvb_public_session',
                                                      secure: Rails.env.production?,
                                                      httponly: true
