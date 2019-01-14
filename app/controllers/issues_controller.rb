# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :scope_project
  before_action :scope_issue, except: [:index, :new, :create]

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
    if @issue.save
      redirect_to project_issue_path(@project, @issue)
    else
      flash[:error] = @issues.errors.full_messages
      render :new
    end
  end

  def show
    comments = @issue.issue_comments.order(:created_at)
    @reporter_discussion_comments = comments.select{ |comment| (comment.commenter == @issue.reporter) || comment.visible_to_reporter? }
    @internal_comments = comments - @reporter_discussion_comments
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

  def issue_params
    params.require(:issue).permit(:description, urls: [])
  end

  def scope_issue
    @issue = Issue.find_by(id: params[:id])
    @issue ||= Issue.find_by(id: params[:issue_id])
    redirect_to :root unless @issue.reporter == current_account || @issue.project.account == current_account
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end
end
