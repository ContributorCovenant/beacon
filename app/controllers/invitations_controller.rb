class InvitationsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project, only: [:create]
  before_action :scope_invitation, except: [:create, :index]
  before_action :enforce_create_permissions, only: [:create]
  before_action :enforce_view_permissions, only: [:show, :accept, :reject]

  def index
    @invitations = current_account.invitations
  end

  def show
  end

  def create
    project = Project.find_by(slug: params[:project_slug])
    invitation = Invitation.new(
      invitation_params.merge(
        account_id: current_account.id,
        project_id: project.id
      )
    )
    if verify_recaptcha(model: invitation) && invitation.save
      flash[:info] = "Invitation sent."
      InvitationsMailer.with(
        invitation: invitation
      ).send_project_invitation.deliver_now
    else
      flash[:error] = invitation.errors.full_messages
    end
    redirect_to project_moderators_path(project)
  end

  def accept
    flash[:info] = "You have accepted the invitation."
    Role.create(account: current_account, project_id: @invitation.project_id)
    @invitation.destroy
    redirect_to @invitation.project
  end

  def reject
    flash[:info] = "You have declined the invitation."
    @invitation.destroy
    redirect_to invitations_path
  end

  private

  def enforce_create_permissions
    render_forbidden && return unless @project.account_id == current_account.id
  end

  def enforce_view_permissions
    render_forbidden && return unless @invitation.email == current_account.email
  end

  def invitation_params
    params.require(:invitation).permit(:is_owner, :email)
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def scope_invitation
    @invitation = Invitation.find_by(params[:id])
  end

end
