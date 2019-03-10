class NotificationService

  def self.notify(account:, project:, issue_id:, issue_comment_id: nil)
    notification = Notification.create(
      project_id: project.id,
      issue_id: issue_id,
      issue_comment_id: issue_comment_id
    )
    account.notification_encrypted_ids << EncryptionService.encrypt(notification.id)
    account.save
    # Notify on new issue creation
    notify_via_sms(account, project, issue_id) if issue_comment_id.nil?
  end

  def self.notified!(account:, issue_id:)
    return unless notifications = account.notifications.where(issue_id: issue_id)
    notifications.destroy_all
    account.notification_encrypted_ids = account.notifications.compact.map{ |n| EncryptionService.encrypt(n.id) }
    account.save
  end

  def self.notify_via_sms(account, project, issue_id)
    return unless account.send_sms_on_issue_open
    return unless account.phone_number
    return unless project.moderator?(account)

    issue = Issue.find(issue_id)
    client = Twilio::REST::Client.new(Setting.sms(:account_sid), Setting.sms(:auth_token))

    begin
      client.messages.create(
        body: "Issue #{issue.issue_number} has been opened on the #{project.name} project. Please sign in to Beacon to review the issue.",
        to: account.phone_number,
        from: Setting.sms(:from)
      )
    rescue
      logger.info("Failed to send SMS")
    end
  end

end
