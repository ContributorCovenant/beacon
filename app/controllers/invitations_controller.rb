class InvitationsController < ApplicationController

  before_action :authenticate_account!
  before_action :scope_project, only: [:create]
  before_action :scope_organization, only: [:create]
  before_action :scope_invitation, except: [:create, :index]
  before_action :enforce_create_permissions, only: [:create]
  before_action :enforce_view_permissions, only: [:accept, :reject]

  def index
    @invitations = current_account.invitations
    redirect_to root_path unless @invitations.any?
  end

  def create
    if project = Project.find_by(slug: params[:project_slug])
      invitation = Invitation.new(
        invitation_params.merge(
          account_id: current_account.id,
          project_id: project.id
        )
      )
    elsif organization = Organization.find_by(slug: params[:organization_slug])
      invitation = Invitation.new(
        invitation_params.merge(
          account_id: current_account.id,
          organization_id: organization.id
        )
      )
    else
      redirect_to root_path
    end

    recaptcha_success = verify_recaptcha(model: invitation)
    if recaptcha_success && invitation.save
      flash[:info] = "Invitation sent."
      if params[:commit] == "Get Invitation Link"
        flash[:info] = "The invitation link for #{invitation.email} is #{invitations_url}."
      else
        InvitationsMailer.with(
          invitation_id: invitation.id
        ).send_invitation.deliver
      end
    else
      ActivityLoggingService.log(current_account, :recaptcha_failures) unless recaptcha_success
      flash[:error] = invitation.errors.full_messages
    end
    redirect_to project_moderators_path(project) if project
    redirect_to organization_moderators_path(organization) if organization
  end

  def accept
    flash[:info] = "You have accepted the invitation."
    if @invitation.project
      Role.create(
        account: current_account,
        project_id: @invitation.project_id,
        is_owner: @invitation.is_owner
      )
      @invitation.destroy
      redirect_to @invitation.project
    elsif @invitation.organization
      Role.create(
        account: current_account,
        organization_id: @invitation.organization_id,
        is_owner: @invitation.is_owner,
        is_default_moderator: true
      )
      @invitation.destroy
      if @invitation.is_owner?
        redirect_to @invitation.organization
      else
        redirect_to projects_path
      end
    end
  end

  def reject
    flash[:info] = "You have declined the invitation."
    @invitation.destroy
    redirect_to invitations_path
  end

  private

  def enforce_create_permissions
    if @project
      render_forbidden && return unless current_account.can_invite_moderator?(@project)
    elsif @organization
      render_forbidden && return unless current_account.can_invite_moderator?(@organization)
    else
      render_forbidden && return
    end
  end

  def enforce_view_permissions
    render_forbidden && return unless @invitation.email == current_account.email
  end

  def invitation_params
    params.require(:invitation).permit(:is_owner, :email, :message)
  end

  def scope_organization
    @organization = Organization.find_by(slug: params[:organization_slug])
  end

  def scope_project
    @project = Project.find_by(slug: params[:project_slug])
  end

  def scope_invitation
    @invitation = Invitation.find_by(id: params[:invitation_id])
    render_not_found unless @invitation
  end

end
