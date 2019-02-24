class IssueSeverityLevelsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :scope_organization
  before_action :enforce_ladder_management_permissions

  def index
    if @project
      @issue_severity_level = IssueSeverityLevel.new(project: @project)
      if @project.organization
        @available_ladders = ["beacon_default", "organization_default", @project.organization.projects.map(&:name)].flatten
      else
        @available_ladders = ["beacon_default", current_account.personal_projects.map(&:name)].flatten
      end
    else
      @issue_severity_level = IssueSeverityLevel.new(organization: @organization)
      @available_ladders = ["beacon_default", @organization.projects.map(&:name)].flatten
    end
  end

  def create
    @issue_severity_level = IssueSeverityLevel.new(issue_severity_level_params.merge(project: @project)) if @project
    @issue_severity_level ||= IssueSeverityLevel.new(issue_severity_level_params.merge(organization: @organization))

    if @issue_severity_level.save
      redirect_to project_issue_severity_levels_path(@project) if @project
      redirect_to organization_issue_severity_levels_path(@organization) if @organization
    else
      flash[:error] = @issue_severity_level.errors.full_messages
      render :index
    end
  end

  def update
    @issue_severity_level = @project.issue_severity_levels.find(params[:id])
    if params[:commit] == "Save"
      if @issue_severity_level.update_attributes(issue_severity_level_params)
        redirect_to project_issue_severity_levels_path(@project)
      else
        flash[:error] = @issue_severity_level.errors.full_messages
      end
    elsif params[:commit] == "Delete"
      @issue_severity_level.destroy
      redirect_to project_issue_severity_levels_path(@project)
    end
  end

  def destroy
    @project.issue_severity_levels.find(params[:id]).destroy
  end

  private

  def enforce_ladder_management_permissions
    if @project
      @current_account_can_manage_ladder = current_account.can_manage_consequence_ladder?(@project)
    elsif @organization
      @current_account_can_manage_ladder = current_account.can_manage_organization?(@organization)
    end
    render_forbidden && return unless @current_account_can_manage_ladder
  end

  def issue_severity_level_params
    params.require(:issue_severity_level).permit(:name, :severity, :label, :example, :consequence)
  end

  def scope_organization
    return unless @organization = Organization.find_by(slug: params[:organization_slug])
    @issue_severity_levels = @organization.issue_severity_levels || []
    @available_severities = (1..10).to_a - @issue_severity_levels.map(&:severity)
    @subject ||= @organization
  end

  def scope_project
    return unless @project = Project.where(slug: params[:project_slug]).includes(:issue_severity_levels).first
    @issue_severity_levels = @project.issue_severity_levels || []
    @available_severities = (1..10).to_a - @issue_severity_levels.map(&:severity)
    @subject = @project
  end

end
