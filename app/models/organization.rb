class Organization < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :slug
  validates_presence_of :name

  belongs_to :account
  has_many :issue_severity_levels
  has_many :roles
  has_many :moderators, through: :roles, source: :account
  has_many :projects

  before_create :set_slug

  attr_accessor :consequence_ladder_default_source

  def consequence_ladder?
    issue_severity_levels.any?
  end

  def default_moderators
    roles.where(is_default_moderator: true).map(&:account)
  end

  def owner?(account)
    owners.include?(account)
  end

  def owners
    roles.where(is_owner: true).includes(:account).map(&:account)
  end

  def respondent_template?
    # respondent_template.present?
    false
  end

  def setup_complete?
    false
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = name.downcase.gsub(/[^a-z0-9]/i, '_')
  end

end
