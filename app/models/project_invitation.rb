class ProjectInvitation < ApplicationRecord

  belongs_to :account
  belongs_to :project

  validates :email, 'valid_email_2/email': { disposable: true, mx: true }

  after_create :send_invitation

  def send_invitation
  end

end
