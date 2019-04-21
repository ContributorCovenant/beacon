# The Griddler handler for processing incoming emails (new issues and issue comments)
class IncomingEmailService

  attr_reader :email

  VALID_MIME_TYPES = [
    "image/gif",
    "image/jpeg",
    "image/png"
  ].freeze

  def initialize(email)
    @email = email
  end

  def process
    return unless project
    if comment_on_existing_issue?
      process_comment
    else
      process_new_issue
    end
  end

  private

  def process_comment
    return unless can_comment_on_issue?
    process_attachments
    notify_moderators_of_new_comment
  end

  def process_new_issue
    return unless validate_can_open_issue_by_email
    create_new_account unless account
    create_issue
    process_attachments
    notify_moderators_of_new_issue
  end

  def account
    @account ||= Account.find_by(email: sender_email)
  end

  def candidate_account
    @new_account = Account.new(
      email: sender_email,
      name: email[:from][:name],
      password: SecureRandom.base64,
      is_external_reporter: true
    )
  end

  def create_new_account
    new_account = candidate_account
    new_account.skip_confirmation_notification!
    new_account.save
  end

  def can_comment_on_issue?
    return false unless comment_on_existing_issue? && account
    return false unless issue.reporter == account
    account.can_comment_on_issue?(issue)
  end

  def comment
    return unless comment_on_existing_issue? && account
    @comment ||= IssueComment.create(
      issue_id: issue.id,
      commenter_id: account.id,
      visible_to_reporter: true,
      text: email.body
    )
  end

  def create_issue
    @issue ||= Issue.create(reporter_id: account.id, project_id: project.id, description: email.body)
  end

  def comment_on_existing_issue?
    issue_number.present?
  end

  def issue
    @issue ||= project.issues.find{ |project_issue| project_issue.issue_number == issue_number }
  end

  def issue_number
    email.subject.scan(/Issue \#([0-9]+)/).last&.first&.to_i
  end

  def notify_reporter_of_unacceptable_issue
    ReporterMailer.with(
      email: sender_email,
      project: project
    ).notify_not_accepting_email_issue.deliver_now
  end

  def notify_moderators_of_new_comment
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
      commenter_kind: "reporter"
    ).notify_of_new_comment.deliver_now
  end

  def notify_moderators_of_new_issue
    project.all_moderators.each do |moderator|
      NotificationService.enqueue_notification(
        account_id: moderator.id,
        project_id: project.id,
        issue_id: issue.id
      )
      NotificationService.enqueue_sms(
        project_id: project.id,
        issue_id: issue.id
      )
    end
    IssueNotificationsMailer.with(
      email: project.moderator_emails,
      project_id: project.id,
      issue_id: issue.id
    ).notify_of_new_issue.deliver_now
  end

  def process_attachments
    valid_attachments.each do |attachment|
      issue.uploads.attach(
        io: attachment.to_io,
        filename: attachment.original_filename,
        content_type: attachment.content_type
      )
    end
  end

  def project
    @project ||= Project.find_by(slug: email.to.first[:token].downcase)
  end

  def project_accepting_issues?
    project.accept_issues_by_email? || project&.organization&.accept_issues_by_email?
  end

  def sender_email
    @sender_email ||= email[:from][:email]
  end

  def valid_attachments
    email.attachments.select{ |attachment| VALID_MIME_TYPES.include?(attachment.content_type) }
  end

  def validate_can_open_issue_by_email
    if project_accepting_issues?
      account&.can_open_issue_on_project?(project) || candidate_account.can_open_issue_on_project?(project)
    else
      notify_reporter_of_unacceptable_issue
      return false
    end
    true
  end

end
