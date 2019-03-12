require 'active_support/concern'
# Account concern to handle third party credentials
module OmniauthHandler

  extend ActiveSupport::Concern

  Account.omniauth_providers.each do |provider|
    define_method("linked_to_#{provider}?") do
      credentials.where(provider: provider.to_s).first.present?
    end
  end

  module ClassMethods

    def from_omniauth(auth)
      from_omniauth_provider_and_uid(auth) || from_omniauth_email(auth)
    end

    def create_from_omniauth(auth)
      account = Account.create(email: auth.info.email,
                               password: Devise.friendly_token[0, 20])
      account.save!
      account.credentials.create(email: auth.info.email,
                                 provider: auth.provider,
                                 uid: auth.uid)
      account.skip_confirmation!
      account
    end

    private

    def find_account_from_omniauth(auth)
      account = Credential.where(provider: auth.provider,
                                 uid: auth.uid)&.first&.account
      account || create_account_from_omniauth(auth)
    end

    def from_omniauth_provider_and_uid(auth)
      Credential.where(provider: auth.provider, uid: auth.uid)&.first&.account
    end

    def from_omniauth_email(auth)
      Account.find_by(email: auth.info.email)
    end

    def create_account_from_omniauth(auth)
      account = Account.create(email: auth.info.email,
                               password: Devise.friendly_token[0, 20])
      account.save!
      account.credentials.create(email: auth.info.email,
                                 provider: auth.provider,
                                 uid: auth.uid)
    end
  end

  private

  def provider_configured?(provider_name)
    Account.omniauth_providers.include?(provider_name.to_sym)
  end

  def can_link_provider?(provider_name)
    provider_configured?(provider_name) && !send("linked_to_#{provider_name}?")
  end

end
