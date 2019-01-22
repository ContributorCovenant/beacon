class NotificationService

  def self.notify(account:, project_id:, issue_id:, issue_comment_id: nil)
    notification = Notification.create(
      project_id: project_id,
      issue_id: issue_id,
      issue_comment_id: issue_comment_id
    )
    account.notification_encrypted_ids << EncryptionService.encrypt(notification.id)
    account.save
  end

  def self.notified!(account:, issue_id:)
    if notifications = account.notifications.where(issue_id: issue_id)
      notifications.destroy_all
      account.notification_encrypted_ids = account.notifications.compact.map{ |n| EncryptionService.encrypt(n.id) }
      account.save
    end
  end

end
