require 'digest'
require 'normailize'

class Account < ApplicationRecord

  include Permissions

  devise :authy_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :authy_authenticatable, :confirmable, :lockable, :timeoutable,
         :trackable, :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable

  devise :omniauthable, omniauth_providers: [:github, :gitlab]
  include OmniauthHandler

  validates_uniqueness_of :normalized_email
  validates :email, 'valid_email_2/email': { disposable: true, mx: true }

  has_one  :account_activity_log, dependent: :destroy
  has_many :abuse_reports, dependent: :delete_all
  has_many :account_issues, dependent: :delete_all
  has_many :account_project_blocks, dependent: :delete_all
  has_many :credentials, inverse_of: :account, dependent: :delete_all
  has_many :roles

  scope :admins, -> { where(is_admin: true) }

  before_validation :normalize_email
  before_create :hash_email
  after_create :associate_respondent_with_issues

  def blocked_from_project?(project)
    account_project_blocks.find_by(project_id: project.id).present?
  end

  def display_name
    return self.name if self.name.present?
    self.email
  end

  def encrypted_id
    EncryptionService.encrypt(self.id)
  end

  def flag!(reason)
    self.update_attributes(
      is_flagged: true,
      flagged_reason: reason,
      flagged_at: Time.zone.now
    )
    projects.each { |project| project.flag!("Owner flagged") }
  end

  def unflag!
    self.update_attributes(
      is_flagged: false,
      flagged_reason: nil,
      flagged_at: nil
    )
    projects.each(&:unflag!)
  end

  def flagged?
    !!is_flagged
  end

  def github_token
    return unless encrypted_token = credentials.find_by(provider: "github")&.token_encrypted
    EncryptionService.decrypt(encrypted_token)
  end

  def gitlab_token
    return unless encrypted_token = credentials.find_by(provider: "gitlab")&.token_encrypted
    EncryptionService.decrypt(encrypted_token)
  end

  def invitations
    Invitation.where(email: self.email)
  end

  def issues
    @issues ||= AccountIssue.issues_for_account(id)
  end

  def linked_to_github?
    credentials.find_by(provider: "github").present?
  end

  def linked_to_gitlab?
    credentials.find_by(provider: "gitlab").present?
  end

  def notification_on_issue_of_kind?(issue_id, commenter_kind)
    issue_notifications = notifications.select{ |notification| notification.issue_id == issue_id }
    !issue_notifications.map(&:issue_comment).compact.find{ |comment| comment.commenter_kind == commenter_kind }.nil?
  end

  def notifications
    @notifications ||= Rails.cache.fetch("#{cache_key_with_version}/notifications", expires_in: 6.hours) do
      Notification.notifications_for_account(self)
    end
  end

  def organizations
    roles.where("organization_id IS NOT NULL")
      .includes(:organization)
      .map(&:organization)
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
  end

  def phone_number=(number)
    self.phone_encrypted = EncryptionService.encrypt(number)
  end

  def phone_number
    return unless self.phone_encrypted.present?
    EncryptionService.decrypt(self.phone_encrypted)
  end

  def projects
    (personal_projects + organization_projects + roles.map(&:project).compact).uniq.sort_by(&:name)
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

  def third_party_credentials?
    credentials.any?
  end

  def total_issues_past_24_hours
    issues.select{ |issue| issue.created_at >= Time.zone.now - 24.hours }.size
  end

  def update_github_token(token)
    return unless github_credentials = credentials.find_by(provider: "github")
    github_credentials.update_attribute(:token_encrypted, EncryptionService.encrypt(token))
  end

  def update_gitlab_token(token)
    return unless gitlab_credentials = credentials.find_by(provider: "gitlab")
    gitlab_credentials.update_attribute(:token_encrypted, EncryptionService.encrypt(token))
  end

  private

  def associate_respondent_with_issues
    return unless invitations = IssueInvitation.where(email: self.normalized_email)

    invitations.each do |invitation|
      next unless issue = Issue.find(EncryptionService.decrypt(invitation.issue_encrypted_id))
      NotificationService.notify(account_id: self.id, project_id: invitation.issue.project.id, issue_id: invitation.issue.id, issue_comment_id: nil)
      issue.update_attribute(:respondent_encrypted_id, EncryptionService.encrypt(self.id))
      AccountIssue.create(account_id: self.id, issue_id: issue.id)
      invitation.destroy
    end
  end

  def hash_email
    self.hashed_email = EncryptionService.hash(self.normalized_email)
  end

  def normalize_email
    return unless email.present?
    normalized = Normailize::EmailAddress.new(self.email).normalized_address
    self.normalized_email = normalized.gsub(/\+.+\@/, "@")
  end

end
