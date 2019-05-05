class Devise::Mailer < Devise.parent_mailer.constantize
  include Devise::Mailers::Helpers

  def welcome
  end

end
