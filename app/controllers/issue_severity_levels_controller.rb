class IssueSeverityLevelsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :enforce_ladder_management_permissions

  def index
    @issue_severity_level = IssueSeverityLevel.new(project: @project)
  end

  def create
    @issue_severity_level = IssueSeverityLevel.new(issue_severity_level_params.merge(project: @project))
    if @issue_severity_level.save
      redirect_to project_issue_severity_levels_path(@project)
    else
      flash[:error] = @issue_severity_level.errors.full_messages
      render :index
    end
  end

  def update
    @issue_severity_level = @project.issue_severity_levels.find(params[:id])
    if @issue_severity_level.update_attributes(issue_severity_level_params)
      redirect_to project_issue_severity_levels_path(@project)
    else
      flash[:error] = @issue_severity_level.errors.full_messages
    end
  end

  def destroy
    @project.issue_severity_levels.find(params[:id]).destroy
  end

  private

  def enforce_ladder_management_permissions
    render_forbidden && return unless current_account.can_manage_consequence_ladder?(@project)
  end

  def issue_severity_level_params
    params.require(:issue_severity_level).permit(:name, :severity, :label, :example, :consequence)
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
    @issue_severity_levels = @project.issue_severity_levels
    @available_severities = (1..10).to_a - [(@issue_severity_levels.last.try(:level) || 0) + 1]
  end

end
