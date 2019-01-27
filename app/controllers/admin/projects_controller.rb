class Admin::ProjectsController < Admin::AdminController

  before_action :enforce_project_permissions
  before_action :scope_project, except: [:index]

  def index
    @projects = Project.public
  end

  def show
  end

  def toggle_flag
    @project.toggle_flagged
  end

  private

  def enforce_project_permissions
    render_forbidden && return unless current_account.can_access_admin_project_dashboard?
  end

  def scope_project
    @project = Project.find(params[:slug])
  end

end
