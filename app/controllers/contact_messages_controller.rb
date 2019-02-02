class ContactMessagesController < ApplicationController

  def new
    @contact_message = ContactMessage.new
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    @contact_message.sender_ip = request.remote_ip
    if verify_recaptcha(model: @contact_message) && @contact_message.save
      notify_on_new_contact_message
      redirect_to root_path
    else
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
    ).notify_on_new_contact_message.deliver_now
  end

end
