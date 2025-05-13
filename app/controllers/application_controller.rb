class ApplicationController < ActionController::Base
  API_SLA = 2.seconds

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :do_not_cache
  before_action :set_locale
  before_action :store_request_id

  around_action :set_and_check_deadline

  helper LinksHelper

  def not_found
    render status: :not_found, plain: 'Not found'
  end

private

  def set_and_check_deadline
    RequestStore.store[:deadline] = Process.clock_gettime(Process::CLOCK_MONOTONIC) + API_SLA
    yield
    elapsed = RequestStore.store[:deadline] - Time.zone.now
    PVB::Instrumentation.append_to_log(deadline_exceeded: elapsed < 0)
  end

  def http_referrer
    request.headers['REFERER']
  end

  def http_user_agent
    request.headers['HTTP_USER_AGENT']
  end

  def do_not_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
  end

  def default_url_options(*)
    { locale: I18n.locale }
  end

  def set_locale
    locale = params[:locale]
    I18n.locale = if locale && I18n.available_locales.include?(locale.to_sym)
                    locale
                  else
                    I18n.default_locale
                  end
  end

  def store_request_id
    PVB::Instrumentation.append_to_log(request_id: request.uuid)
    RequestStore.store[:request_id] = request.uuid
    Sentry.set_extras(request_id: request.uuid)
  end
end
