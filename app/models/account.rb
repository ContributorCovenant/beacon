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
  validates :email, 'valid_email_2/email': { disposable: true, mx: true }

  has_many :abuse_reports
  has_many :account_issues
  has_many :account_project_blocks
  has_many :projects
  has_many :roles

  scope :admins, -> { where(is_admin: true) }

  before_validation :normalize_email
  before_create :hash_email
  after_create :associate_respondent_with_issues

  def blocked_from_project?(project)
    account_project_blocks.find_by(project_id: project.id).present?
  end

  def notification_on_issue_of_kind?(issue_id, commenter_kind)
    issue_notifications = notifications.select{ |notification| notification.issue_id == issue_id }
    !issue_notifications.map(&:issue_comment).compact.find{ |comment| comment.commenter_kind == commenter_kind }.nil?
  end

  def issues
    @issues ||= AccountIssue.issues_for_account(id)
  end

  def organizations
    roles.where("organization_id IS NOT NULL AND is_owner = ?", true)
      .includes(:organization)
      .map(&:organization)
  end

  def projects
    (personal_projects + organization_projects).sort_by(&:name)
  end

  def organization_projects
    organizations.map(&:projects).flatten
  end

  def personal_projects
    roles.where("project_id IS NOT NULL AND is_owner = ?", true)
      .includes(:project)
      .map(&:project)
      .select{ |project| project.organization_id.nil? }
      .uniq
      .sort_by(&:name)
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

  def submitted_abuse_report_for?(account)
    abuse_reports
      .submitted
      .includes(:abuse_report_subject)
      .map(&:abuse_report_subject)
      .find{ |subject| subject.account_id == account.id }
      .present?
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
