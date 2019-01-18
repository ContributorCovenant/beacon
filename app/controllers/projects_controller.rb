class ProjectsController < ApplicationController
  before_action :authenticate_account!
  before_action :scope_project, only: [:show, :edit, :delete, :update]
  before_action :enforce_existing_project_permissions, except: [:index, :new, :create]
  before_action :enforce_project_creation_permissions, only: [:new, :create]

  def index
    # TODO: this will need to be scoped differently once there are multiple moderators per project
    @projects = current_account.projects.order(:name)
  end

  def new
    @project = Project.new(name: 'My Project')
  end

  def create
    @project = Project.new(project_params.merge(account_id: current_account.id))
    if @project.save
      redirect_to @project
    else
      flash[:error] = @project.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def show
  end

  def update
    if @project.update_attributes(project_params)
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

  def project_params
    params.require(:project).permit(:name, :url, :coc_url, :description)
  end

  def scope_project
    @project = Project.find_by(slug: params[:slug])
    @settings = @project.project_setting
    @issues = @project.issues
  end
end
