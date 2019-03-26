class RespondentsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :enforce_permissions
  before_action :scope_actor
  before_action :scope_issues

  def show
    breadcrumb "Projects", projects_path
    breadcrumb @project.name, project_path(@project)
    @display_name = @project.project_setting.allow_anonymous_issues ? "Anonymous" : @actor.email
    @blocked = @project.account_project_blocks.where(account_id: @actor.id).any?
    @block = @project.account_project_blocks.find_by(account_id: @actor.id) || @project.account_project_blocks.build(account_id: @actor.id)
  end

  private

  def enforce_permissions
    render_forbidden && return unless current_account.can_moderate_project?(@project)
  end

  def scope_actor
    @actor = Account.find(params[:id])
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def scope_issues
    @issues = @project.issues.select{ |issue| issue.respondent == @actor }
  end

end
