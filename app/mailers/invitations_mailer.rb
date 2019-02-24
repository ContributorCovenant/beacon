class InvitationsMailer < ApplicationMailer

  def send_project_invitation
    @invitation = params[:invitation]
    @project_name = @invitation.project.name
    @inviter_email = @invitation.account.email
    mail(to: @invitation.email, subject: "Beacon: Invitation to Moderate #{@project_name}")
  end

end
