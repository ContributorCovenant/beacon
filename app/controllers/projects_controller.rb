class ProjectsController < ApplicationController
  before_action :authenticate_account!
  before_action :scope_project, except: [:index, :new, :create]
  before_action :scope_organization, except: [:index, :create, :update]
  before_action :scope_organizations, expect: [:index]
  before_action :enforce_existing_project_permissions, except: [:index, :new, :create]
  before_action :enforce_project_creation_permissions, only: [:new, :create]

  def index
    breadcrumb "Projects", projects_path
    @projects = current_account.projects
  end

  def moderators
    if @organization
      breadcrumb "Organizations", organizations_path
      breadcrumb @organization.name, organization_path(@organization)
    else
      breadcrumb "Projects", projects_path
    end
    breadcrumb @project.name, project_path(@project)
    @invitation = Invitation.new(project_id: @project.id)
    @invitations = @project.invitations
    @moderators = @project.all_moderators
  end

  def remove_moderator
    Role.where(account_id: params[:account_id], project_id: @project.id).destroy_all
    redirect_to project_moderators_path
  end

  def new
    if @organization
      breadcrumb "Organizations", organizations_path
      breadcrumb @organization.name, organization_path(@organization)
    else
      breadcrumb "Projects", projects_path
    end
    @project = Project.new(name: 'My Project', organization_id: params[:organization_id])
  end

  def create
    @project = Project.new(project_params.merge(account_id: current_account.id))
    if @project.organization
      render_forbidden && return unless current_account.can_manage_organization?(@project.organization)
    end
    if @project.save
      Role.create(project_id: @project.id, account_id: current_account.id, is_owner: true)
      ActivityLoggingService.log(current_account, :projects_created)
      redirect_to @project
    else
      flash[:error] = @project.errors.full_messages
      @organizations = current_account.organizations
      render :new
    end
  end

  def edit
    if @organization
      breadcrumb "Organizations", organizations_path
      breadcrumb @organization.name, organization_path(@organization)
    else
      breadcrumb "Projects", projects_path
    end
    breadcrumb @project.name, project_path(@project)
  end

  def show
    if @organization
      breadcrumb "Organizations", organizations_path
      breadcrumb @organization.name, organization_path(@organization)
    else
      breadcrumb "Projects", projects_path
    end
    breadcrumb @project.name, project_path(@project)
    unless @project.coc_url.present?
      flash[:error] = "This project does not have a code of conduct URL. To set it, click 'Edit' below."
    end
    @report = TransparencyReportingService.new(@project)
  end

  def ownership
    if @organization
      breadcrumb "Organizations", organizations_path
      breadcrumb @organization.name, organization_path(@organization)
    else
      breadcrumb "Projects", projects_path
    end
    breadcrumb @project.name, project_path(@project)
    @github_token = current_account.github_token
    @gitlab_token = current_account.gitlab_token
  end

  def confirm_ownership
    @project.update_attribute(:confirmation_token_url, project_params[:confirmation_token_url])
    if params[:commit] == "Confirm via GitHub"
      method = "github"
      current_account.update_github_token(project_params[:token])
      confirmation = ProjectConfirmationService.confirm!(
        @project,
        current_account.credentials.find_by(provider: "github"),
        "github"
      )
    elsif params[:commit] == "Confirm via GitLab"
      current_account.update_gitlab_token(project_params[:token])
      method = "gitlab"
      confirmation = ProjectConfirmationService.confirm!(
        @project,
        current_account.credentials.find_by(provider: "gitlab"),
        "gitlab"
      )
    else
      confirmation = ProjectConfirmationService.confirm!(@project, project_params[:confirmation_token_url], "file")
      method = "file"
    end
    if confirmation
      flash[:info] = 'Your ownership has been verified.'
      redirect_to @project
    else
      if method == "file"
        flash[:error] = "No token found or invalid token."
      else
        flash[:error] = "You are either not the owner of this project, or this project is a fork."
      end
      redirect_to project_ownership_path
    end
  end

  def update
    project_params.delete(:name)
    previous_repo_url = @project.repo_url.to_s
    if @project.update_attributes(project_params)
      @project.unconfirm_ownership! if previous_repo_url != project_params[:repo_url].to_s
      flash[:notice] = 'The project was successfully updated.'
      redirect_to @project
    else
      flash[:error] = @project.errors.full_messages
      render :edit
    end
  end

  def token
    token = "BEACON_TOKEN=#{@project.confirmation_token}"
    if @project.repo_url
      send_data token, filename: "beacon", type: "text/plain"
    else
      send_data token, filename: "beacon.txt", type: "text/plain"
    end
  end

  private

  def enforce_existing_project_permissions
    render_forbidden && return unless current_account.can_manage_project?(@project) || current_account.can_moderate_project?(@project)
  end

  def enforce_project_creation_permissions
    render_forbidden && return unless current_account.can_create_project?
  end

  def project_params
    params.require(:project).permit(
      :name,
      :url,
      :coc_url,
      :repo_url,
      :description,
      :organization_id,
      :confirmation_token_url,
      :token,
      :is_event,
      :duration,
      :frequency,
      :attendees
    )
  end

  def scope_organization
    if @project
      @organization = @project.organization
    else
      @organization = Organization.find_by(id: params[:organization_id])
    end
  end

  def scope_organizations
    @organizations = current_account.organizations
  end

  def scope_project
    @project = Project.find_by(slug: params[:slug]) || Project.find_by(slug: params[:project_slug])
    render_not_found && return unless @project
    @settings = @project.project_setting
    @issues = @project.issues
  end
end
