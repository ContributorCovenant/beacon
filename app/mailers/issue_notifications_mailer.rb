class IssueNotificationsMailer < ApplicationMailer

  def autoresponder
    assign_objects
    @email = params[:email]
    @text = params[:text]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} has been opened")
  end

  def notify_on_status_change
    assign_objects
    @emails = params[:emails]
    mail(bcc: @emails, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} status has changed")
  end

  def notify_of_new_issue
    assign_objects
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} has been opened")
  end

  def notify_of_new_comment
    assign_objects
    @commenter_kind = params[:commenter_kind]
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} issue has a new comment")
  end

  def notify_of_new_survey
    assign_objects
    @survey = Survey.find(params[:survey_id])
    @kind = @survey.kind
    @email = params[:email]
    mail(to: @email, subject: "Beacon: #{@project.name} Issue ##{@issue.issue_number} issue has a new survey")
  end

  private

  def assign_objects
    @project = Project.find(params[:project_id])
    @issue = Issue.find(params[:issue_id])
  end
end
