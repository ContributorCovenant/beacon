class Credential < ApplicationRecord
  belongs_to :account, inverse_of: :credentials

  validates :account, presence: true
  validates :email, presence: true
  validates :uid, presence: true
  validates :provider, presence: true

  validate :provider_account_configuration

  def self.find_with_omniauth(auth)
    find_by(uid: auth.uid, provider: auth.provider)
  end

  def self.new_with_omniauth(auth)
    create(uid: auth.uid, provider: auth.provider, email: auth.info.email)
  end

  private

  def provider_account_configuration
    return true if Account.omniauth_providers.include?(self.provider.to_sym)
    errors.add(:provider, "This Provider is not configured")
  end

end
