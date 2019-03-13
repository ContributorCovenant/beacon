class Project < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :url
  validates_uniqueness_of :slug
  validates_presence_of :name, :url

  belongs_to :account
  belongs_to :organization, optional: true
  has_one :project_setting, dependent: :destroy
  has_one :respondent_template, dependent: :destroy
  has_many :abuse_report_subjects, dependent: :destroy
  has_many :account_project_blocks, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :issue_severity_levels, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :project_issues, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :moderators, through: :roles, source: :account

  before_create :set_slug
  after_create :make_settings

  attr_accessor :consequence_ladder_default_source

  scope :for_directory, -> { where(public: true, setup_complete: true).order("name ASC") }

  def accepting_issues?
    public? && !paused?
  end

  def all_moderators
    (moderators + organization_moderators + owners).uniq
  end

  def confirmation_token
    EncryptionService.hash(id)
  end

  def confirmation_token_url_default
    (url + "/blob/master/beacon.txt").gsub(/\/\/blob/, "/blob")
  end

  def consequence_ladder?
    issue_severity_levels.any?
  end

  def issues
    @issues ||= ProjectIssue.issues_for_project(id)
  end

  def issue_count_from_past_24_hours
    issues.select{ |issue| issue.created_at >= Time.zone.now - 24.hours }.size
  end

  def moderator?(account)
    all_moderators.include?(account)
  end

  def moderator_emails
    all_moderators.map(&:email)
  end

  def obscure_reporter_email?
    project_setting.allow_anonymous_issues
  end

  def organization_moderators
    return [] unless self.organization
    self.organization.moderators
  end

  def owner?(account)
    roles.where(is_owner: true, account_id: account.id).any?
  end

  def owners
    roles.where(is_owner: true).includes(:account).map(&:account)
  end

  def ownership_confirmed?
    confirmed_at.present?
  end

  def paused?
    project_setting.paused?
  end

  def respondent_template?
    respondent_template.present?
  end

  def check_setup_complete?
    complete = false unless public?
    complete ||= false unless verified_settings?
    complete ||= false unless consequence_ladder?
    complete ||= false unless ownership_confirmed?
    complete ||= false unless respondent_template?
    complete ||= false unless coc_url.present?
    complete = complete.nil? ? true : false
    update_attribute(:setup_complete, complete) unless setup_complete == complete
    return complete
  end

  def show_in_directory?
    return false unless public?
    return false unless setup_complete?
    return false if is_flagged
    return true
  end

  def to_param
    slug
  end

  def flag!
    self.update_attribute(:is_flagged, true)
  end

  def toggle_flagged
    self.update_attribute(:is_flagged, !is_flagged)
  end

  def verified_settings?
    project_setting.updated_at != project_setting.created_at
  end

  private

  def set_slug
    self.slug = name.downcase.gsub(/[^a-z0-9]/i, '_')
  end

  # TODO: Eventually this will inherit from an org's project template
  def make_settings
    create_project_setting
  end
end
