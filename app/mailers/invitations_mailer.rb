class InvitationsMailer < ApplicationMailer

  def send_invitation
    @invitation = Invitation.find(params[:invitation_id])
    @project_name = @invitation.project&.name
    @organization_name = @invitation.organization&.name
    @inviter_email = @invitation.account.email
    @subject_name = @project_name || @organization_name
    @message = @invitation.message
    mail(to: @invitation.email, subject: "Beacon: Invitation to Moderate #{@subject_name}")
  end

end
