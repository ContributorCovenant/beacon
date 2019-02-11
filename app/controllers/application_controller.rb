class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception, prepend: true
  before_action :set_raven_context
  before_action :configure_permitted_parameters, if: :devise_controller?

  if Rails.env.production?
    http_basic_authenticate_with name: ENV['HTTP_AUTH_USER'], password: ENV['HTTP_AUTH_PASSWORD']
  end

  def render_not_found
    SuspiciousActivityLog.create(
      controller: self.class.to_s,
      action: action_name,
      ip_address: request.remote_ip,
      params: params.to_json,
      account_id: current_account ? current_account.id : nil
    )
    render "errors/show", status: 404
  end

  def render_forbidden
    SuspiciousActivityLog.create(
      controller: self.class.to_s,
      action: action_name,
      ip_address: request.remote_ip,
      params: params.to_json,
      account_id: current_account ? current_account.id : nil
    )
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

  protected

  def signed_in?
    !current_account.nil?
  end

end
