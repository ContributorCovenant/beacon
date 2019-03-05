module OmniConcern
  extend ActiveSupport::Concern

  def create
    @auth = request.env["omniauth.auth"]
    assign_credential
    if signed_in?
      redirect_or_link_credential
    elsif @credential.account.present?
      # The credential we found had a user associated with it so let's
      # just log them in here. Sign in scenario
      @account = @credential.account
      sign_in_account
    else
      sign_up_or_link_credential
    end
  end

  private

  def sign_in_account
    sign_in_and_redirect @account, event: :authentication
    set_flash_message(:notice, :success, kind: @auth.provider) if is_navigational_format?
  end

  def assign_credential
    @credential = Credential.find_with_omniauth(@auth)
    @credential ||= Credential.new_with_omniauth(@auth)
  end

  def redirect_and_notify
    redirect_to root_url, notice: "Already linked that account!"
    set_flash_message(:notice, :success, kind: @auth.provider) if is_navigational_format?
  end

  def link_credential_and_notify
    @credential.account = current_account
    @credential.save
    redirect_to root_url, notice: "You have successfully linked your account.!"
    set_flash_message(:notice, :success_link, kind: @auth.provider) if is_navigational_format?
  end

  def sign_up_account
    @account = Account.create_from_omniauth(@auth)
    if @account.save!
      sign_in_account
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def link_credential
    @credential.account = @account
    if @credential.save!
      sign_in_account
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def redirect_or_link_credential
    if @credential.account == current_account
      # User is signed in so they are trying to link an credential with their
      # account. But we found the credential and the user associated with it
      # is the current user. So the credential is already associated with
      # this user. So let's display an error message.
      redirect_and_notify
    else
      # The credential is not associated with the current_account so lets
      # associate the credential
      link_credential_and_notify
    end
  end

  def sign_up_or_link_credential
    @account = Account.find_by(email: @auth.info.email)
    if @account
      # The credential has an account that is associated with it but it's not linked yet
      # We link it and we sign in
      link_credential
    else
      # Sign up
      sign_up_account
    end
  end

end
