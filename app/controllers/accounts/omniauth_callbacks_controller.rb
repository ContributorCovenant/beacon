module Accounts
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    # You should configure your model like this:
    # devise :omniauthable, omniauth_providers: [:twitter]

    %w(github gitlab).each do |provider|
      define_method(provider) do
        auth = request.env["omniauth.auth"]
        # The user is signed in and wants to link his account
        # See what to do with this call when the account is linked already
        @credential = Credential.find_with_omniauth(auth)
        if @credential.nil?
          # If no identity was found, create a brand new one here
          @credential = Credential.create_with_omniauth(auth)
        end

        if signed_in?
          if @credential.account == current_account
            # User is signed in so they are trying to link an identity with their
            # account. But we found the identity and the user associated with it
            # is the current user. So the identity is already associated with
            # this user. So let's display an error message.
            redirect_to root_url, notice: "Already linked that account!"
            set_flash_message(:notice, :success, kind: auth.provider) if is_navigational_format?
          else
            # The identity is not associated with the current_account so lets
            # associate the identity
            @credential.account = current_account
            @credential.save
            redirect_to root_url, notice: "Successfully linked that account!"
            set_flash_message(:notice, :success_link, kind: auth.provider) if is_navigational_format?
          end
        else
          if @credential.account.present?
            # The identity we found had a user associated with it so let's
            # just log them in here. Sing in scenario
            current_account = @credential.account
            sign_in_and_redirect current_account, event: :authentication
            set_flash_message(:notice, :success, kind: auth.provider) if is_navigational_format?
          else
            @account = Account.find_by(email: auth.info.email)
            unless @account
              # Sing up
              current_account = Account.create_from_omniauth(auth)
              current_account.credentials << @credential
              if current_account.save!
                sign_in_and_redirect current_account, event: :authentication
                set_flash_message(:notice, :success, kind: auth.provider) if is_navigational_format?
              else
                session["devise.facebook_data"] = request.env["omniauth.auth"]
                redirect_to new_user_registration_url
              end
            else
              # The identity has an account that is associated with it but it's not linked yet
              # We link it and we sign in
              @credential.account = @account
              if @credential.save!
                sign_in_and_redirect @account, notice: "The account is linked to #{auth.provider}"
                set_flash_message(:notice, :success, kind: auth.provider) if is_navigational_format?
              else
                session["devise.facebook_data"] = request.env["omniauth.auth"]
                redirect_to new_user_registration_url
              end                
            end
          end
        end
      end
    end

    # More info at:
    # https://github.com/plataformatec/devise#omniauth

    # GET|POST /resource/auth/twitter
    # def passthru
    #   super
    # end

    # GET|POST /users/auth/twitter/callback
    def failure
      super
    end

    # protected

    # The path used when OmniAuth fails
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end
  end
end
