class OrganizationsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_organization, except: [:index, :new]
  before_action :scope_projects, only: [:show, :update]
  before_action :enforce_view_permissions, only: [:show]
  before_action :enforce_management_permissions, only: [:edit, :update, :delete]

  def index
    @organizations = Role.where(
      "account_id = ? AND organization_id IS NOT NULL AND is_owner = ?",
      current_account.id,
      true
    ).includes(:organization).map(&:organization).sort(&:name)
  end

  def new
    @organization = Organization.new(account_id: current_account.id)
  end

  def show
  end

  def edit
  end

  def update
    @organization.update_attributes(organization_params)
    render :show
  end

  def clone_ladder
    source = ladder_params[:consequence_ladder_default_source]
    if source == "Beacon Default"
      IssueSeverityLevel.clone_from_template_for_organization(@organization)
    end
    redirect_to organization_issue_severity_levels_path(@organization)
  end

  private

  def enforce_management_permissions
    current_account.can_manage_organization?(@organization)
  end

  def enforce_view_permissions
    current_account.can_view_organization?(@organization)
  end

  def organization_params
    params.require(:organization).permit(
      :name,
      :url,
      :coc_url,
      :description
    )
  end

  def ladder_params
    params.require(:organization).permit(:consequence_ladder_default_source)
  end

  def scope_organization
    @organization = Organization.find_by(slug: params[:slug])
  end

  def scope_projects
    @projects = @organization.projects.order("name ASC")
  end

end
