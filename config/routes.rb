Rails.application.routes.draw do
  if defined?(JasmineRails) && Rails.env.test?
    mount JasmineRails::Engine => '/specs'
  end

  get '/', to: redirect(ENV.fetch('GOVUK_START_PAGE', '/en/request'))
  get '/.well_known/security.txt', to: redirect('https://raw.githubusercontent.com/ministryofjustice/security-guidance/master/contact/vulnerability-disclosure-security.txt')

  match 'exception', to: 'errors#test', via: %i[ get post ]

  if Rails.env.test?
    match 'error_handling', to: 'errors#show', via: :get
  end

  constraints format: 'json' do
    get 'ping', to: 'ping#index'
    get 'healthcheck', to: 'healthcheck#index'
    get 'info', to: 'info#index'
    get 'health', to: 'health#index'
  end

  constraints format: 'html' do
    # Old pvb1 path to start a booking
    get '/prisoner', to: redirect('/en/request')

    # Another Gov.uk start path
    get '/prisoner-details', to: redirect('/en/request')

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
        get 'privacy-policy', action: :show, id: 'privacy_policy'
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

  namespace :staff do
    namespace :api do
      resources :feedback,        only: %i[ create ]
      resources :prisons,         only: %i[ index show ]
      resources :slots,           only: %i[ index ]
      resources :visits,          only: %i[ create show destroy ]
      post '/validations/prisoner', to: 'validations#prisoner'
      post '/validations/visitors', to: 'validations#visitors'
    end
  end

  match '*path', to: 'application#not_found', via: :all
end
