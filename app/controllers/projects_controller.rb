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
        source: current_account.projects.find{ |project| project.name == source },
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
    unless @project.coc_url.present?
      flash[:error] = "This project does not have a code of conduct URL. To set it, click 'Edit' below."
    end
  end

  def ownership
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
    params.require(:project).permit(
      :name,
      :url,
      :coc_url,
      :repo_url,
      :description,
      :organization_id,
      :confirmation_token_url,
      :token
    )
  end

  def scope_organizations
    @organizations = current_account.organizations
  end

  def scope_project
    @project = Project.find_by(slug: params[:slug]) || Project.find_by(slug: params[:project_slug])
    render_not_found unless @project
    @settings = @project.project_setting
    @issues = @project.issues
  end
end
