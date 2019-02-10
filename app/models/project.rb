class Project < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :url
  validates_uniqueness_of :slug
  validates_presence_of :name, :url, :coc_url

  belongs_to :account
  has_one :project_setting
  has_one :respondent_template
  has_many :abuse_report_subjects
  has_many :account_project_blocks
  has_many :issue_severity_levels
  has_many :notifications
  has_many :project_issues

  before_create :set_slug
  after_create :make_settings

  attr_accessor :consequence_ladder_default_source

  def self.public_scope
    ProjectSetting.includes(:project).where(include_in_directory: true).order("projects.name ASC").map(&:project)
  end

  def accepting_issues?
    public? && !paused?
  end

  def confirmation_token_url
    url + "beacon.txt"
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
    moderators.include?(account)
  end

  def moderators
    @moderators ||= [self.account]
  end

  def moderator_emails
    moderators.map(&:email)
  end

  def obscure_reporter_email?
    project_setting.allow_anonymous_issues
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

  def setup_complete?
    return false unless public?
    return false unless verified_settings?
    return false unless consequence_ladder?
    return false unless ownership_confirmed?
    return false unless respondent_template?
    return true
  end

  def update_setup_complete
    update_attribute(:setup_complete, setup_complete?)
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
