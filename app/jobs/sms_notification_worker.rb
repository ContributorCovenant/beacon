class SmsNotificationWorker
  @queue = :sms_notifications

  def self.perform(project, issue)
    NotificationService.notify_moderators_on_issue_via_sms(project, issue)
  end

end
