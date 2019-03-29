class NotificationService

  def self.enqueue_notification(account_id:, project_id:, issue_id:, issue_comment_id: nil)
    Resque.enqueue(NotificationWorker, account_id, project_id, issue_id, issue_comment_id)
  end

  def self.enqueue_sms(project, issue)
    Resque.enqueue(SmsNotificationWorker, project, issue)
  end

  def self.notify(account_id:, project_id:, issue_id:, issue_comment_id: nil)
    project = Project.find(project_id)
    account = Account.find(account_id)

    notification = Notification.create(
      project_id: project.id,
      issue_id: issue_id,
      issue_comment_id: issue_comment_id
    )
    account.notification_encrypted_ids << EncryptionService.encrypt(notification.id)
    account.save
  end

  def self.notified!(account:, issue_id:)
    return unless notifications = account.notifications.where(issue_id: issue_id)
    notifications.destroy_all
    account.notification_encrypted_ids = account.notifications.compact.map{ |n| EncryptionService.encrypt(n.id) }
    account.save
  end

  def self.notify_moderators_on_issue_via_sms(project, issue)
    client = Twilio::REST::Client.new(Setting.sms(:account_sid), Setting.sms(:auth_token))

    project.moderators.each do |account|
      next unless account.send_sms_on_issue_open
      next unless account.phone_number
      next unless project.moderator?(account)

      begin
        client.messages.create(
          body: "Issue #{issue.issue_number} has been opened on the #{project.name} project. Please sign in to Beacon to review the issue.",
          to: account.phone_number,
          from: Setting.sms(:from)
        )
      rescue StandardError => e
        Rails.logger.info("Failed to send SMS: #{e} #{e.backtrace}")
      end
    end
  end

end
