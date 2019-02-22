class IssueNotificationsMailerPreview < ActionMailer::Preview

  def notify_on_status_change
    params = {
      project: Project.first,
      issue: Issue.new(id: "aca9adb2-1ec0-4995-be5f-1d365919960f", issue_number: 101),
      emails: "foo@bar.com"
    }
    IssueNotificationsMailer.with(params).notify_on_status_change
  end

  def notify_of_new_issue
    params = {
      project: Project.first,
      issue: Issue.new(id: "aca9adb2-1ec0-4995-be5f-1d365919960f", issue_number: 101, created_at: DateTime.now),
      email: "foo@bar.com"
    }
    IssueNotificationsMailer.with(params).notify_of_new_issue
  end

  def notify_of_new_comment
    params = {
      project: Project.first,
      issue: Issue.new(id: "aca9adb2-1ec0-4995-be5f-1d365919960f", issue_number: 101, created_at: DateTime.now),
      commenter_kind: "reporter",
      email: "moderator@bar.com"
    }
    IssueNotificationsMailer.with(params).notify_of_new_comment
  end

end
