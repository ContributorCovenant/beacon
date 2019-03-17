module Admin

  class OrganizationsController < Admin::AdminController

    before_action :enforce_organization_permissions
    before_action :scope_organization, except: [:index]

    def index
      @organizations = Organization.includes(:account).all.order('name ASC')
    end

    def show
      @projects = @organization.projects
    end

    def flag
      @organization.flag!(flag_organization_params[:flagged_reason])
      redirect_to admin_organization_path(@organization)
    end

    def unflag
      @organization.unflag!
      redirect_to admin_organization_path(@organization)
    end

    private

    def enforce_organization_permissions
      render_forbidden && return unless current_account.can_access_admin_organization_dashboard?
    end

    def flag_organization_params
      params.require(:organization).permit(:flagged_reason)
    end

    def scope_organization
      @organization = Organization.find_by(slug: params[:id]) || Organization.find_by(slug: params[:organization_id])
    end

  end

end
