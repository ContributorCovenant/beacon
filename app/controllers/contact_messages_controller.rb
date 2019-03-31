class ContactMessagesController < ApplicationController

  def new
    @contact_message = ContactMessage.new
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    @contact_message.sender_ip = request.remote_ip
    recaptcha_success = verify_recaptcha(model: @contact_message)
    if recaptcha_success && @contact_message.save
      notify_on_new_contact_message
      flash[:info] = "Your message has been sent. A Beacon administrator will reply soon."
      redirect_to root_path
    else
      ActivityLoggingService.log(current_account, :recaptcha_failures) unless recaptcha_success
      flash[:error] = @contact_message.errors.full_messages
      render :new
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:sender_email, :message)
  end

  def notify_on_new_contact_message
    AdminMailer.with(
      contact_message: @contact_message
    ).notify_on_new_contact_message.deliver!
  end

end
