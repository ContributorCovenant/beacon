require File.join(Rails.root, "lib/tor")

module Accounts
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

    PROXY_HEADERS = %w(FORWARDED X_FORWARDED_FOR VIA USERAGENT_VIA PROXY_CONNECTION XPROXY_CONNECTION PC_REMOTE_ADDR CLIENT_IP).freeze

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    def create
      # This code is from Devise's SessionsController - we need to check
      # headers after successful login *without* rendering a result yet.
      # It's hard to split the responsibility for rendering a response
      # with a prewritten parent class.
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)

      if ENV["BLOCK_LOGIN_VIA_PROXY"]
        header_names = request.headers.to_h.keys.map { |k| k.upcase.tr("-", "_").gsub(/^HTTP_/, "") }
        bad_headers = PROXY_HEADERS & header_names
        unless bad_headers.empty?
          # This is a correct login but it occurred via an HTTP proxy, which isn't allowed.
          # Since we don't want mysterious failures for honest users, we don't just return a normal
          # your-password-was-wrong login failure.
          #
          # The tradeoff here is that it's possible to try to brute-force passwords from
          # a proxy or exit node since incorrect passwords can be distinguished from
          # "no login via Tor/Proxy" responses. So it's more important to prevent
          # brute-forcing via bcrypt, strong passwords and/or throttling.
          #
          # If we checked this *before* login, we would want to handle this
          # differently - render_forbidden adds a suspicious activity log to the
          # database, which can facilitate a DOS if it can be done without an
          # account.
          sign_out
          return render_forbidden
        end
      end

      if ENV["BLOCK_LOGIN_VIA_TOR"]
        if Tor::DNSEL.include?(current_account.current_sign_in_ip)
          # This is a correct login but it occurred via a Tor exit node, which isn't allowed.
          # Since we don't want mysterious failures for honest users, we don't just return a normal
          # your-password-was-wrong login failure.
          sign_out
          return render_forbidden
        end
      end

      respond_with resource, location: after_sign_in_path_for(resource)
    end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end
