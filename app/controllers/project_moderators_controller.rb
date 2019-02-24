class ProjectModeratorsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project
  before_action :enforce_existing_project_permissions

  def index
    @project_invitation = ProjectInvitation.new(project_id: @project.id)
    @moderators = @project.all_moderators
  end

  def create
    invitation = ProjectInvitation.new(
      moderator_invitation_params.merge(
        account_id: current_account.id,
        project_id: @project.id
      )
    )
    if verify_recaptcha(model: invitation) && invitation.save
      flash[:message] = "Your invitation has been sent."
    else
      flash[:error] = invitation.errors.full_messages
    end
    redirect_to project_moderators_path(@project)
  end

  private

  def enforce_existing_project_permissions
    render_forbidden && return unless current_account.can_manage_project?(@project)
  end

  def moderator_invitation_params
    params.require(:project_invitation).permit(:email)
  end

  def scope_organization_moderators
    @org_moderators = @project.organization.map(&:moderators)
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

end
