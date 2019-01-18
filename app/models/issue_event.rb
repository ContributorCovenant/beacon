class IssueEvent < ApplicationRecord
  attr_accessor :actor_id

  belongs_to :issue

  before_create :set_actor_encrypted_id

  def actor
    @actor ||= Account.find(EncryptionService.decrypt(actor_encrypted_id))
  end

  private

  def set_actor_encrypted_id
    self.actor_encrypted_id = EncryptionService.encrypt(actor_id)
  end
end
