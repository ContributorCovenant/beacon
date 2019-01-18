class IssuesController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_issue, except: [:index, :new, :create]
  before_action :enforce_viewing_permissions, only: [:show]
  before_action :enforce_moderation_permissions, only: [:acknowledge, :dismiss, :resolve, :reopen]
  before_action :enforce_issue_creation_permissions, only: [:new, :create]

  def index
    issues = current_account.issues
    @open_issues = issues.select(&:open?)
    @closed_issues = issues - @open_issues
  end

  def new
    @issue = Issue.new(project_id: @project.id, reporter_id: current_account.id)
  end

  def create
    @issue = Issue.new(issue_params.merge(project_id: @project.id, reporter_id: current_account.id))
    if verify_recaptcha(model: @issue) && @issue.save
      redirect_to project_issue_path(@project, @issue)
    else
      flash[:error] = @issues.errors.full_messages
      render :new
    end
  end

  def show
    @reporter_discussion_comments = @issue.comments_visible_to_reporter
    @respondent_discussion_comments = @issue.comments_visible_to_respondent
    @internal_comments = @issue.comments_visible_only_to_moderators
    @comment = IssueComment.new
  end

  def acknowledge
    @issue.acknowledge!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  def dismiss
    @issue.dismiss!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  def resolve
    @issue.resolve!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  def reopen
    @issue.reopen!(account_id: current_account.id)
    notify_on_status_change
    redirect_to [@project, @issue]
  end

  private

  def enforce_issue_creation_permissions
    render(status: :forbidden, plain: nil) && return unless current_account.can_open_issue_on_project?(@project)
  end

  def enforce_moderation_permissions
    render(status: :forbidden, plain: nil) && return unless current_account.can_moderate_project?(@project)
  end

  def enforce_viewing_permissions
    render(status: :forbidden, plain: nil) && return unless current_account.can_view_issue?(@issue)
  end

  def issue_params
    params.require(:issue).permit(:description, urls: [])
  end

  def notify_on_status_change
    emails = [@issue.reporter.email, @issue.respondent.try(:email), @project.moderator_emails - [current_account.email]]
    IssueNotificationsMailer.with(
      emails: emails,
      project: @issue.project,
      issue: @issue
    ).notify_on_status_change.deliver_now
  end

  def scope_issue
    @issue = Issue.find_by(id: params[:id])
    @issue ||= Issue.find_by(id: params[:issue_id])
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

end
