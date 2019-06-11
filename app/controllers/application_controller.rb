class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception, prepend: true
  before_action :set_raven_context
  before_action :configure_permitted_parameters, if: :devise_controller?

  if Rails.env.production? && self.controller_name != "emails"
    http_basic_authenticate_with name: ENV['HTTP_AUTH_USER'], password: ENV['HTTP_AUTH_PASSWORD']
  end

  breadcrumb 'Home', :root_path

  def render_not_found
    params[:account].delete(:password)
    ActivityLoggingService.log(current_account, :four_o_fours) if current_account
    SuspiciousActivityLog.create(
      controller: self.class.to_s,
      action: action_name,
      ip_address: request.remote_ip,
      params: params.to_json,
      account_id: current_account ? current_account.id : nil
    )
    SuspiciousActivityLog.throttle(request.remote_ip)
    render "errors/show", status: 404
  end

  def render_forbidden
    params[:account].delete(:password)
    SuspiciousActivityLog.create(
      controller: self.class.to_s,
      action: action_name,
      ip_address: request.remote_ip,
      params: params.to_json,
      account_id: current_account ? current_account.id : nil
    )
    SuspiciousActivityLog.throttle(request.remote_ip)
    render "errors/forbidden", status: :forbidden
  end

  private

  def set_raven_context
    Raven.user_context(email: current_account ? current_account.email : "public user")
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone_number, :send_sms_on_issue_open])
  end

end
