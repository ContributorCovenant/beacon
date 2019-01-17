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
    @issue = Issue.new(project_id: @project.id, account_id: current_account.id)
  end

  def create
    @issue = Issue.new(issue_params.merge(project_id: @project.id, account_id: current_account.id))
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
    redirect_to [@project, @issue]
  end

  def dismiss
    @issue.dismiss!(account_id: current_account.id)
    redirect_to [@project, @issue]
  end

  def resolve
    @issue.resolve!(account_id: current_account.id)
    redirect_to [@project, @issue]
  end

  def reopen
    @issue.reopen!(account_id: current_account.id)
    redirect_to [@project, @issue]
  end

  private

  def enforce_issue_creation_permissions
    render(status: :forbidden, plain: nil) && return unless @project.accepting_issues?
  end

  def enforce_moderation_permissions
    render(status: :forbidden, plain: nil) && return unless @issue.account_can_moderate?(current_account)
  end

  def enforce_viewing_permissions
    render(status: :forbidden, plain: nil) && return unless @issue.account_can_view?(current_account)
  end

  def issue_params
    params.require(:issue).permit(:description, urls: [])
  end

  def scope_issue
    @issue = Issue.find_by(id: params[:id])
    @issue ||= Issue.find_by(id: params[:issue_id])
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

end
