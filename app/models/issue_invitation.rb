class IssueInvitation < ApplicationRecord
  attr_accessor :summary, :reporter_email

  def issue
    Issue.find(EncryptionService.decrypt(self.issue_encrypted_id))
  end

end
