class IssueComment < ApplicationRecord
  attr_accessor :commenter_id, :context

  belongs_to :issue

  before_create :set_commenter_encrypted_id

  scope :visible_to_reporter, -> { where(visible_to_reporter: true) }
  scope :visible_to_respondent, -> { where(visible_to_respondent: true) }
  scope :visible_only_to_moderators, -> { where(visible_only_to_moderators: true) }

  def commenter
    @commenter ||= Account.find(EncryptionService.decrypt(commenter_encrypted_id))
  end

  def commenter_kind
    return "reporter" if commenter == issue.reporter
    return "respondent" if commenter == issue.respondent
    return "moderator"
  end

  private

  def set_commenter_encrypted_id
    self.commenter_encrypted_id = EncryptionService.encrypt(commenter_id)
  end
end
