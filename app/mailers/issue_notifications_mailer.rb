class IssueNotificationsMailer < ApplicationMailer

  def autoresponder
    @project = params[:project]
    @issue = params[:issue]
    @email = params[:email]
    @text = params[:text]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} has been opened")
  end

  def notify_on_status_change
    @project = params[:project]
    @issue = params[:issue]
    @emails = params[:emails]
    mail(bcc: @emails, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} status has changed")
  end

  def notify_of_new_issue
    @project = params[:project]
    @issue = params[:issue]
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} has been opened")
  end

  def notify_of_new_comment
    @project = params[:project]
    @issue = params[:issue]
    @commenter_kind = params[:commenter_kind]
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} issue has a new comment")
  end

  def notify_of_new_survey
    @project = params[:project]
    @issue = params[:issue]
    @survey = params[:survey]
    @kind = @survey.kind
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} issue has a new survey")
  end

end
