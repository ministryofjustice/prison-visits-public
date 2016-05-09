Rails.application.routes.draw do
  get '/', to: redirect(ENV.fetch('GOVUK_START_PAGE', '/en/request'))

  match 'exception', to: 'errors#test', via: %i[ get post ]

  if Rails.env.test?
    match 'error_handling', to: 'errors#show', via: :get
  end

  # Old pvb1 path to start a booking
  get '/prisoner', to: redirect('/en/request')

  # Another Gov.uk start path
  get '/prisoner-details', to: redirect('/en/request')

  constraints format: 'json' do
    get 'ping', to: 'ping#index'
    get 'healthcheck', to: 'healthcheck#index'
  end

  # Old pvb1 link that users got in an email
  get 'status/:id', controller: :pvb1_paths, action: :status, as: :pvb1_status

  scope '/:locale', locale: /en|cy/ do
    get '/', to: redirect('/%{locale}/request')

    resources :booking_requests, path: 'request', only: %i[ index create ]
    resources :visits, only: %i[ show ]
    resources :cancellations, path: 'cancel', only: %i[ create ]
    resources :feedback_submissions, path: 'feedback', only: %i[ new create ]

    controller 'high_voltage/pages' do
      get 'cookies', action: :show, id: 'cookies'
      get 'terms-and-conditions', action: :show, id: 'terms_and_conditions'
      get 'unsubscribe', action: :show, id: 'unsubscribe'
    end
  end

  get '/:locale/prison/*rest', to: redirect { |_, request|
    "#{Rails.configuration.staff_url}#{request.fullpath}"
  }

  get '/:locale/metrics/*rest', to: redirect { |_, request|
    "#{Rails.configuration.staff_url}#{request.fullpath}"
  }

  get '/staff/*rest', to: redirect { |_, request|
    "#{Rails.configuration.staff_url}#{request.fullpath}"
  }
end
