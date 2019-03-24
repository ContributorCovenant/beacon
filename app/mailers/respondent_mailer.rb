class RespondentMailer < ApplicationMailer

  def notify_existing_account_of_issue
    @project_name = params[:project_name]
    @email = params[:email]
    @text = params[:text]
    @issue = params[:issue]
    mail(to: @email, subject: "Beacon: Your attention is needed on a code of conduct issue")
  end

  def notify_new_account_of_issue
    @project_name = params[:project_name]
    @email = params[:email]
    @text = params[:text]
    mail(to: @email, subject: "Beacon: Your attention is needed on a code of conduct issue")
  end

end
