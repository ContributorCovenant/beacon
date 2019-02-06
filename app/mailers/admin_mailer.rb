class AdminMailer < ApplicationMailer

  def notify_on_abuse_report
    @report = params[:report]
    @project = params[:project]
    @reporter = @report.account
    mail(to: Setting.emails(:abuse), subject: "Beacon: New Abuse Report")
  end

  def notify_on_new_contact_message
    @message = params[:contact_message]
    mail(to: Setting.emails(:support), subject: "Beacon: New Contact Form")
  end

  def notify_on_flag_request
    @reporter = params[:reporter]
    @account = params[:account]
    @reason = params[:reason]
    @report = params[:report]
    mail(to: Setting.emails(:abuse), subject: "Beacon: New Account Block Request")
  end

end
