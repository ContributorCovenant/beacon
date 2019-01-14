# frozen_string_literal: true

class AccountIssue < ApplicationRecord
  belongs_to :account

  validates_uniqueness_of :issue_encrypted_id

  before_create :encrypt_issue_id

  attr_accessor :issue_id

  def self.issues_for_account(account_id)
    encrypted_issue_ids = where(account_id: account_id).pluck(:issue_encrypted_id)
    issue_ids = encrypted_issue_ids.map{ |id| EncryptionService.decrypt(id) }
    Issue.where(id: issue_ids)
  end

  private

  def encrypt_issue_id
    self.issue_encrypted_id = EncryptionService.encrypt(issue_id)
  end
end
