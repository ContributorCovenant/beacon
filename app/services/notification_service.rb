class NotificationService

  def self.notify(project:, issue:, issue_comment: nil, account:)
    Notification.create(
      project_id: project.id,
      issue_id: issue.id,
      issue_comment_id: issue_comment.try(:id),
      account_id: account.id
    )
  end

end
