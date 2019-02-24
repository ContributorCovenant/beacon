class Role < ApplicationRecord

  belongs_to :account
  belongs_to :organization, optional: true
  belongs_to :project, optional: true

  scope :for_account, ->(account) { where(account_id: account.id).first }

end
