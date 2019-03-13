class IssueInvitationsController < ApplicationController

  before_action :scope_all
  before_action :enforce_permissions

  def new
    @invitation = IssueInvitation.new(summary: @project.respondent_template.populate_from(@issue, issue_url(@issue)))
  end

  def create
    create_for_reporter && return if invitation_params[:reporter_email].present?
    if invitation_params[:summary].empty? || invitation_params[:email].empty?
      flash[:error] = "You must provide an email and an issue summary for the respondent."
      render :new && return
    end

    normalized_email = Normailize::EmailAddress.new(invitation_params[:email]).normalized_address
    project = @issue.project

    if account = Account.find_by(normalized_email: normalized_email)
      RespondentMailer.with(
        email: account.email,
        project_name: project.name,
        text: project.respondent_template.populate_from(@issue, issue_url(@issue)),
        issue: @issue
      ).notify_existing_account_of_issue.deliver_now
      AccountIssue.create(issue_id: @issue.id, account: account)
      NotificationService.notify(account_id: account.id, project_id: @project.id, issue_id: @issue.id)
      @issue.update_attribute(:respondent_encrypted_id, EncryptionService.encrypt(account.id))
    else
      IssueInvitation.create(
        email: Normailize::EmailAddress.new(invitation_params[:email]).normalized_address,
        issue_encrypted_id: EncryptionService.encrypt(@issue.id)
      )
      RespondentMailer.with(
        email: account.email,
        project_name: project.name,
        text: project.respondent_template.populate_from(@issue, issue_url(@issue))
      ).notify_new_account_of_issue.deliver_now
    end
    @issue.update_attribute(:respondent_summary, invitation_params[:summary])
    flash[:message] = "The respondent has been notified and invited to comment on this issue."
    redirect_to project_issue_path(@project, @issue)
  end

  private

  def create_for_reporter
    normalized_email = Normailize::EmailAddress.new(invitation_params[:reporter_email]).normalized_address

    if account = Account.find_by(normalized_email: normalized_email)
      ReporterMailer.with(
        email: account.email,
        project_name: @issue.project.name
      ).notify_existing_account_of_issue.deliver_now
      AccountIssue.create(issue_id: @issue.id, account: account)
      NotificationService.notify(account: account, project: @project, issue_id: @issue.id)
      @issue.update_attribute(:reporter_encrypted_id, EncryptionService.encrypt(account.id))
      flash[:message] = "The reporter has been invited to this issue."
    else
      flash[:error] = "No account found for that email address."
    end
    redirect_to project_issue_path(@project, @issue)
  end

  def enforce_permissions
    render_forbidden && return unless current_account.can_invite_respondent?(@issue)
  end

  def scope_all
    @project = Project.find_by(slug: params[:project_slug])
    @issue = Issue.find(params[:issue_id])
  end

  def invitation_params
    params[:issue_invitation].permit(:email, :reporter_email, :summary)
  end

end
