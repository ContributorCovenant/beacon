class IssueEvent < ApplicationRecord

  attr_accessor :actor_id

  before_create :set_actor_encrypted_id

  def actor
    @actor ||= Account.find(EncryptionService.decrypt(self.actor_encrypted_id))
  end

  private

  def set_actor_encrypted_id
    self.actor_encrypted_id = EncryptionService.encrypt(self.actor_id)
  end

end
