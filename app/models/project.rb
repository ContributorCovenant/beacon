class Project < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :url
  validates_uniqueness_of :slug
  validates_presence_of :name, :url, :coc_url

  belongs_to :account
  has_one :project_setting
  has_many :project_issues
  has_many :account_project_blocks
  has_many :issue_severity_levels
  has_many :notifications

  before_create :set_slug
  after_create :make_settings

  attr_accessor :consequence_ladder_default_source

  def issues
    @issues ||= ProjectIssue.issues_for_project(id)
  end

  def to_param
    slug
  end

  def public?
    project_setting.include_in_directory
  end

  def accepting_issues?
    public? && !paused?
  end

  def consequence_ladder?
    issue_severity_levels.any?
  end

  def verified_settings?
    project_setting.updated_at != project_setting.created_at
  end

  def moderator?(account)
    moderators.include?(account)
  end

  def moderators
    [self.account]
  end

  def moderator_emails
    moderators.map(&:email)
  end

  def obscure_reporter_email?
    project_setting.allow_anonymous_issues
  end

  def paused?
    project_setting.paused?
  end

  def setup_complete?
    public? && verified_settings? && consequence_ladder?
  end

  private

  def set_slug
    self.slug = name.downcase.gsub(/^[a-zA-Z0-9]/,'_')
  end

  # TODO: Eventually this will inherit from an org's project template
  def make_settings
    create_project_setting
  end
end
