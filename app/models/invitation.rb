class Invitation < ApplicationRecord

  belongs_to :account
  belongs_to :project, optional: true
  belongs_to :organization, optional: true

  validates :email, 'valid_email_2/email': { disposable: true, mx: true }
  validates_uniqueness_of :email, scope: :project
  validates_uniqueness_of :email, scope: :organization

end
