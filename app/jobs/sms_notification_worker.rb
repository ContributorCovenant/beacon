class SmsNotificationWorker
  @queue = :sms_notifications

  def self.perform(project_id, issue_id)
    NotificationService.notify_moderators_on_issue_via_sms(project_id, issue_id)
  end

end
