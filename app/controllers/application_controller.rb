class ApplicationController < ActionController::Base

  if Rails.env.production?
    http_basic_authenticate_with name: ENV['HTTP_AUTH_USER'], password: ENV['HTTP_AUTH_PASSWORD']
  end

  def render_forbidden
    SuspiciousActivityLog.create(
      controller: self.class.to_s,
      action: action_name,
      ip_address: request.remote_ip,
      params: params.to_json,
      account_id: current_account ? current_account.id : nil
    )
    render(status: :forbidden, plain: "Oh no you don't.")
  end

end
