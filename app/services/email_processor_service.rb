class EmailProcessorService

  attr_reader :email, :project

  def initialize(email)
    @email = email
    @project = Project.find_by(slug: email.to.first[:token])
  end

  def process
    return unless project
    notify_reporter_of_unacceptable_issue && return unless project.accept_issues_by_email? || project&.organization&.accept_issues_by_email?
    return unless account.can_open_issue_on_project?(project)
    if issue_number = email.subject.scan(/Issue \#([0-9]+)/).last&.first
      issue = project.issues.find{ |i| i.issue_number == issue_number.to_i }
      comment = IssueComment.create(
        issue_id: issue.id,
        commenter_id: account.id,
        visible_to_reporter: true,
        text: email.body
      )
      notify_moderators(issue, comment)
    else
      issue = Issue.create(reporter_id: account.id, project_id: project.id, description: email.body)
    end
    if email.attachments.any?
      email.attachments.each do |attachment|
        issue.uploads << attachment
      end
    end
  end

  private

  def account
    @account = Account.find_by(email: email.from[:email])
    return @account if @account
    @account = Account.new(
      email: email.from[:email],
      name: email.from[:name],
      password: SecureRandom.base64,
      is_external_reporter: true
    )
    @account.skip_confirmation_notification!
    @account.save
    @account
  end

  def notify_reporter_of_unacceptable_issue
    ReporterMailer.with(
      email: email.from[:email],
      project: project
    ).notify_not_accepting_email_issue.deliver_now
  end

  def notify_moderators(issue, comment)
    project.all_moderators.each do |moderator|
      NotificationService.enqueue_notification(
        account_id: moderator.id,
        project_id: project.id,
        issue_id: issue.id,
        issue_comment_id: comment.id
      )
    end
    IssueNotificationsMailer.with(
      email: project.moderator_emails,
      project_id: project.id,
      issue_id: issue.id,
      commenter_kind: "reporter",
    ).notify_of_new_comment.deliver
  end

end
