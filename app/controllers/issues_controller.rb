class IssuesController < ApplicationController

  before_action :scope_project
  before_action :scope_issue, only: [:show]

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
  end

  private

  def issue_params
    params.require(:issue).permit(:description, urls: [])
  end

  def scope_issue
    @issue = Issue.find(params[:id])
    redirect_to :root unless @issue.reporter == current_account || @issue.project.account == current_account
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

end
