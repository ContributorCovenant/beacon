class EmailProcessorService

  attr_reader :email

  def initialize(email)
    @email = email
  end

  def process
    return unless project = Project.find_by(slug: email.to.first[:token])
    notify_reporter(project) && return unless project.accept_issues_by_email? || project&.organization&.accept_issues_by_email?
    return unless account.can_open_issue_on_project?(project)
    issue = Issue.create(reporter_id: account.id, project_id: project.id, description: email.body)
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

  def notify_reporter(project)
    ReporterMailer.with(
      email: email.from[:email],
      project: project
    ).notify_not_accepting_email_issue.deliver_now
  end

end
