module Accounts
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    include OmniConcern
    # You should configure your model like this:
    # devise :omniauthable, omniauth_providers: [:twitter]

    %w(github gitlab).each do |provider|
      define_method(provider) do
        create
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
