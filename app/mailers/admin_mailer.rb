class AdminMailer < ApplicationMailer

  def notify_on_abuse_report
    @report = params[:report]
    @project = params[:project]
    @reporter = @report.account
    mail(to: admin_emails, subject: "Beacon: New Abuse Report")
  end

  def notify_on_new_contact_message
    @message = params[:contact_message]
    mail(to: admin_emails, subject: "Beacon: New Contact Form")
  end

  private

  def admin_emails
    Account.admins.pluck(:email)
  end

end
