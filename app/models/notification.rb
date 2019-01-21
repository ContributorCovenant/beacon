class Notification < ApplicationRecord

  belongs_to :project
  belongs_to :issue
  belongs_to :issue_comment, optional: true

  scope :with_project, -> { where("project_id IS NOT NULL") }
  scope :with_issue,   -> { where("issue_id IS NOT NULL") }
  scope :with_comment,   -> { where("issue_comment_id IS NOT NULL") }
  scope :for_project,  -> (project_id) { where(project_id: project_id) }
  scope :for_issue,    -> (issue_id) { where(issue_id: issue_id) }

  def self.notifications_for_account(account)
    where(id: account.notification_encrypted_ids.map{ |id| EncryptionService.decrypt(id) })
  end

end
