require 'digest'
require 'normailize'

class Account < ApplicationRecord

  has_many :credentials, inverse_of: :account, dependent: :delete_all

  include Permissions

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :confirmable, :lockable, :timeoutable, :trackable,
         :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable

  devise :omniauthable, omniauth_providers: [:github, :gitlab]
  include OmniauthHandler

  validates_uniqueness_of :normalized_email
  validates :email, 'valid_email_2/email': { disposable: true, mx: true }

  has_many :abuse_reports
  has_many :account_issues
  has_many :account_project_blocks
  has_many :projects

  scope :admins, -> { where(is_admin: true) }

  before_validation :normalize_email
  before_create :hash_email
  after_create :associate_respondent_with_issues


  def blocked_from_project?(project)
    account_project_blocks.find_by(project_id: project.id).present?
  end

  def submitted_abuse_report_for?(account)
    abuse_reports
      .submitted
      .includes(:abuse_report_subject)
      .map(&:abuse_report_subject)
      .find{ |subject| subject.account_id == account.id }
      .present?
  end

  def issues
    @issues ||= AccountIssue.issues_for_account(id)
  end

  def total_issues_past_24_hours
    issues.select{ |issue| issue.created_at >= Time.zone.now - 24.hours }.size
  end

  def notifications
    @notifications ||= Notification.notifications_for_account(self)
  end

  def reputation
    "good"
  end

  def toggle_flagged
    self.update_attribute(:is_flagged, !is_flagged)
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
