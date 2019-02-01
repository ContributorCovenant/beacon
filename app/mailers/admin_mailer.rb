class AdminMailer < ApplicationMailer

  def notify_on_abuse_report
    @report = params[:report]
    @project = params[:project]
    @reporter = @report.account
    @admin_emails = Account.admins.pluck(:email)
    mail(to: @admin_emails, subject: "Beacon: New Abuse Report")
  end

end
