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

  def self.notified!(account, notification_encrypted_id)
    notification = Notification.find(EncryptionService.decrypt(notification_encrypted_id))
    notification.destroy
    account.notification_encrypted_ids.delete(notification_encrypted_id)
    account.save
  end

end
