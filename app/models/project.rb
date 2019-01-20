class Project < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :url
  validates_uniqueness_of :slug
  validates_presence_of :name, :url, :coc_url

  belongs_to :account
  has_one :project_setting
  has_many :project_issues
  has_many :issue_severity_levels

  before_create :set_slug
  after_create :make_settings

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

  def account_can_manage?(account)
    account == self.account
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

  def paused?
    project_setting.paused?
  end

  def obscure_reporter_email?
    project_setting.allow_anonymous_issues
  end

  private

  def set_slug
    self.slug = name.downcase.tr(' ', '-')
  end

  # TODO: Eventually this will inherit from an org's project template
  def make_settings
    create_project_setting
  end
end
