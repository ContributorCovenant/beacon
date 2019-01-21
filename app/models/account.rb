require 'digest'
require 'normailize'

class Account < ApplicationRecord

  include Permissions

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
         :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable

  validates_uniqueness_of :normalized_email

  has_many :projects
  has_many :account_issues
  has_many :account_project_blocks
  has_many :notifications

  before_validation :normalize_email
  before_create :hash_email
  after_create :associate_respondent_with_issues

  def blocked_from_project?(project)
    account_project_blocks.find_by(project_id: project.id).present?
  end

  def issues
    @issues ||= AccountIssue.issues_for_account(id)
  end

  private

  def associate_respondent_with_issues
    return unless invitations = IssueInvitation.where(email: self.normalized_email)

    invitations.each do |invitation|
      next unless issue = Issue.find(EncryptionService.decrypt(invitation.issue_encrypted_id))

      issue.update_attribute(:respondent_encrypted_id, EncryptionService.encrypt(self.id))
      AccountIssue.create(account_id: self.id, issue_id: issue.id)
      invitation.destroy
    end
  end

  def normalize_email
    normalized = Normailize::EmailAddress.new(self.email).normalized_address
    self.normalized_email = normalized.gsub(/\+.+\@/, "@")
  end

  def hash_email
    self.hashed_email = EncryptionService.hash(self.normalized_email)
  end

end
