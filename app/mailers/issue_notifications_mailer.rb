class IssueNotificationsMailer < ApplicationMailer

  def notify_reporter_of_status_change
    @project = params[:project]
    @issue = params[:issue]
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} issue has been updated")
  end

  def notify_on_comment
    @project = params[:project]
    @issue = params[:issue]
    @commenter_kind = params[:commenter_kind]
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} issue has a new comment")
  end

end
