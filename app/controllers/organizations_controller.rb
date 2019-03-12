class OrganizationsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_organization, except: [:index, :new, :create]
  before_action :scope_projects, only: [:show, :update]
  before_action :enforce_view_permissions, except: [:index, :new, :create]
  before_action :enforce_management_permissions, only: [:edit, :update, :delete]

  def index
    @organizations = Role.where(
      "account_id = ? AND organization_id IS NOT NULL AND is_owner = ?",
      current_account.id,
      true
    ).includes(:organization).map(&:organization).sort_by(&:name)
  end

  def new
    @organization = Organization.new(account_id: current_account.id)
  end

  def create
    @organization = Organization.new(organization_params.merge(account_id: current_account.id))
    if @organization.save
      Role.create(organization_id: @organization.id, account_id: current_account.id, is_owner: true)
      redirect_to @organization
    else
      flash[:error] = @organization.errors.full_messages
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    @organization.update_attributes(organization_params)
    render :show
  end

  def import_projects_from_github
    results = GithubImportService.new(current_account, @organization).import_projects
    if results[:success]
      flash[:info] = "Successfully imported #{results[:count]} project(s)."
    else
      flash[:error] = "Could not import projects: #{results[:error]}."
    end
    redirect_to organization_path(@organization)
  end

  def import_projects_from_gitlab
    results = GitlabImportService.new(current_account, @organization).import_projects
    if results[:success]
      flash[:info] = "Successfully imported #{results[:count]} project(s)."
    else
      flash[:error] = "Could not import projects: #{results[:error]}."
    end
    redirect_to organization_path(@organization)
  end

  def clone_ladder
    source = ladder_params[:consequence_ladder_default_source]
    if source == "Beacon Default"
      IssueSeverityLevel.clone_from_template_for_organization(@organization)
    end
    redirect_to organization_issue_severity_levels_path(@organization)
  end

  def moderators
    @invitation = Invitation.new(organization_id: @organization.id)
    @invitations = @organization.invitations
    @moderators = @organization.moderators
  end

  def remove_moderator
    Role.where(account_id: params[:account_id], organization_id: @organization.id).destroy_all
    redirect_to organization_moderators_path
  end

  private

  def enforce_management_permissions
    render_forbidden && return unless current_account.can_manage_organization?(@organization)
  end

  def enforce_view_permissions
    render_forbidden && return unless current_account.can_view_organization?(@organization)
  end

  def organization_params
    params.require(:organization).permit(
      :name,
      :url,
      :coc_url,
      :description,
      :remote_org_name
    )
  end

  def ladder_params
    params.require(:organization).permit(:consequence_ladder_default_source)
  end

  def scope_organization
    @organization = Organization.find_by(slug: params[:slug]) || Organization.find_by(slug: params[:organization_slug])
    render_not_found unless @organization
  end

  def scope_projects
    @projects = @organization.projects.order("name ASC")
  end

end
