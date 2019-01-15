require 'digest'
require 'normailize'

class Account < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
         :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable

  validates_uniqueness_of :normalized_email

  has_many :projects
  has_many :account_issues

  before_create :normalize_email
  before_create :hash_email
  after_create :associate_respondent_with_issues

  def issues
    @issues ||= AccountIssue.issues_for_account(self.id)
  end

  private

  def associate_respondent_with_issues
    if invitations = IssueInvitation.where(email: self.normalized_email)
      invitations.each do |invitation|
        if issue = Issue.find(EncryptionService.decrypt(invitation.issue_encrypted_id))
          issue.update_attribute(:respondent_encrypted_id, EncryptionService.encrypt(self.id))
          AccountIssue.create(account_id: self.id, issue_id: issue.id)
        end
        invitation.destroy
      end
    end
  end

  def hash_email
    self.hashed_email = Digest::MD5.hexdigest(self.normalized_email)
  end

  def normalize_email
    normalized = Normailize::EmailAddress.new(self.email).normalized_address
    self.normalized_email = normalized.gsub(/\+.+\@/, "@")
  end

end
