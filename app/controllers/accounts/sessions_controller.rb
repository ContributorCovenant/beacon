require File.join(Rails.root, "lib/tor")

module Accounts
  class SessionsController < Devise::SessionsController
    # before_action :configure_sign_in_params, only: [:create]

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

      if ENV["BLOCK_LOGIN_VIA_TOR"]
        if Tor::DNSEL.include?(current_account.current_sign_in_ip)
          # This is a correct login but it occurred via a Tor exit node, which isn't allowed.
          # Since we don't want mysterious failures for honest users, we don't just return a normal
          # your-password-was-wrong login failure.
          Rails.logger.info("Blocked login by Tor")
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
