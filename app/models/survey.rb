class Survey < ApplicationRecord

  attr_accessor :account_id, :issue_id

  belongs_to :project

  before_save :encrypt_account_id
  before_save :encrypt_issue_id

  scope :reporter, -> { where(kind: "reporter") }
  scope :respondent, -> { where(kind: "respondent") }

  def account
    @account ||= Account.find(EncryptionService.decrypt(self.account_encrypted_id))
  end

  def issue
    @issue ||= Issue.find(EncryptionService.decrypt(issue_encrypted_id))
  end

  private

  def encrypt_account_id
    self.account_encrypted_id = EncryptionService.encrypt(account_id)
  end

  def encrypt_issue_id
    self.issue_encrypted_id = EncryptionService.encrypt(issue_id)
  end

end
