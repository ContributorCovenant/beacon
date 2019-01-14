# frozen_string_literal: true

class ProjectIssue < ApplicationRecord
  validates_uniqueness_of :issue_encrypted_id

  before_create :encrypt_issue_id

  attr_accessor :issue_id

  def self.issues_for_project(project_id)
    encrypted_issue_ids = where(project_id: project_id).pluck(:issue_encrypted_id)
    issue_ids = encrypted_issue_ids.map{ |id| EncryptionService.decrypt(id) }
    Issue.where(id: issue_ids)
  end

  private

  def encrypt_issue_id
    self.issue_encrypted_id = EncryptionService.encrypt(issue_id)
  end
end
