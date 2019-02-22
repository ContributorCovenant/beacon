class AdminMailerPreview < ActionMailer::Preview

  def notify_on_abuse_report
    report = AbuseReport.new(
      id: "aca9adb2-1ec0-4995-be5f-1d365919960f",
      account_id: Account.first.id,
      project: Project.first,
      description: "This person is being abusive."
    )
    params = {
      report: report,
      project: report.project
    }
    AdminMailer.with(params).notify_on_abuse_report
  end

  def notify_on_new_contact_message
    message = ContactMessage.new(
      sender_email: "foo@bar.com",
      message: "I think you're doing an amazing job so far. Keep it up!"
    )
    AdminMailer.with(contact_message: message).notify_on_new_contact_message
  end

  def notify_on_flag_request
    report = AbuseReport.new(
      id: "aca9adb2-1ec0-4995-be5f-1d365919960f",
      account_id: Account.first.id,
      description: "This person appears to be a bot.",
      reportee: Account.last
    )
    params = {
      reporter: Account.first,
      account: Account.last,
      reason: report.description,
      report: report
    }
    AdminMailer.with(params).notify_on_flag_request
  end

end
