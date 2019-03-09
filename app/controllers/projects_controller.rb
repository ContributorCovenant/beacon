class ProjectsController < ApplicationController
  before_action :authenticate_account!
  before_action :scope_project, except: [:index, :new, :create]
  before_action :scope_organizations, only: [:new, :edit]
  before_action :enforce_existing_project_permissions, except: [:index, :new, :create]
  before_action :enforce_project_creation_permissions, only: [:new, :create]

  def index
    @projects = current_account.projects
  end

  def clone_ladder
    source = ladder_params[:consequence_ladder_default_source]
    if source == "Beacon Default"
      IssueSeverityLevel.clone_from_template_for_project(@project)
    elsif source == "Organization Default"
      IssueSeverityLevel.clone_from_org_template_for_project(@project)
    else
      IssueSeverityLevel.clone_from_existing_project(
        source: current_account.projects.find_by(name: source),
        target: @project
      )
    end
    redirect_to project_issue_severity_levels_path(@project)
  end

  def moderators
    @invitation = Invitation.new(project_id: @project.id)
    @invitations = @project.invitations
    @moderators = @project.all_moderators
  end

  def remove_moderator
    Role.where(account_id: params[:account_id], project_id: @project.id).destroy_all
    redirect_to project_moderators_path
  end

  def new
    @project = Project.new(name: 'My Project', organization_id: params[:organization_id])
  end

  def create
    @project = Project.new(project_params.merge(account_id: current_account.id))
    if @project.organization
      render_forbidden && return unless current_account.can_manage_organization?(@project.organization)
    end
    if @project.save
      Role.create(project_id: @project.id, account_id: current_account.id, is_owner: true)
      redirect_to @project
    else
      flash[:error] = @project.errors.full_messages
      @organizations = current_account.organizations
      render :new
    end
  end

  def edit
  end

  def show
  end

  def ownership
  end

  def confirm_ownership
    ProjectConfirmationService.confirm!(@project)
    redirect_to @project
  end

  def update
    project_params.delete(:name)
    previous_url = @project.url
    if @project.update_attributes(project_params)
      @project.update_attribute(:confirmed_at, nil) if previous_url != project_params[:url]
      flash[:notice] = 'The project was successfully updated.'
      redirect_to @project
    else
      render :edit
    end
  end

  private

  def enforce_existing_project_permissions
    render_forbidden && return unless current_account.can_manage_project?(@project) || current_account.can_moderate_project?(@project)
  end

  def enforce_project_creation_permissions
    render_forbidden && return unless current_account.can_create_project?
  end

  def ladder_params
    params.require(:project).permit(:consequence_ladder_default_source)
  end

  def project_params
    params.require(:project).permit(:name, :url, :coc_url, :description, :organization_id)
  end

  def scope_organizations
    @organizations = current_account.organizations
  end

  def scope_project
    if @project = Project.find_by(slug: params[:slug]) || Project.find_by(slug: params[:project_slug])
      @settings = @project.project_setting
      @issues = @project.issues
    else
      render "errors/not_found"
      return false
    end
  end
end
