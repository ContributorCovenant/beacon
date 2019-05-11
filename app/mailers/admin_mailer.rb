class AdminMailer < ApplicationMailer

  def notify_on_abuse_report
    @report = AbuseReport.find(params[:report_id])
    @project = Project.find(params[:project_id])
    @reporter = @report&.account
    mail(to: Setting.emails(:abuse), subject: "Beacon: New Abuse Report")
  end

  def notify_on_new_contact_message
    @message = params[:contact_message]
    mail(to: Setting.emails(:support), subject: "Beacon: New Contact Form")
  end

  def notify_on_flag_request
    @reporter = Account.find(params[:reporter_id])
    @account = Account.find(params[:account_id])
    @reason = params[:reason]
    @report = AbuseReport.find(params[:report_id])
    mail(to: Setting.emails(:abuse), subject: "Beacon: New Account Flag Request")
  end

  def notify_on_project_published
    @project = params[:project]
    mail(to: Setting.emails(:support), subject: "Beacon: New Project Published (#{@project.name})")
  end

end
