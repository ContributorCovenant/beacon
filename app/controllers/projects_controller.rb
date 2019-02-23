class ProjectsController < ApplicationController
  before_action :authenticate_account!
  before_action :scope_project, except: [:index, :new, :create]
  before_action :enforce_existing_project_permissions, except: [:index, :new, :create]
  before_action :enforce_project_creation_permissions, only: [:new, :create]

  def index
    @projects = current_account.projects.order(:name)
  end

  def clone_ladder
    source = ladder_params[:consequence_ladder_default_source]
    if source == "Beacon Default"
      IssueSeverityLevel.clone_from_template_for_project(@project)
    else
      IssueSeverityLevel.clone_from_existing_project(
        source: current_account.projects.find_by(name: source),
        target: @project
      )
    end
    redirect_to project_issue_severity_levels_path(@project)
  end

  def new
    @project = Project.new(name: 'My Project', organization_id: params[:organization_id])
    @organizations = current_account.organizations
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
    render_forbidden && return unless current_account.can_manage_project?(@project)
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

  def scope_project
    @project = Project.find_by(slug: params[:slug]) || Project.find_by(slug: params[:project_slug])
    @settings = @project.project_setting
    @issues = @project.issues
  end
end
