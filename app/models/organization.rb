class Organization < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :slug
  validates_presence_of :name

  belongs_to :account
  has_many :invitations
  has_many :issue_severity_levels, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_one :respondent_template, dependent: :destroy

  before_create :set_slug

  attr_accessor :consequence_ladder_default_source

  def consequence_ladder?
    issue_severity_levels.any?
  end

  def moderators
    roles.where("is_default_moderator = ? OR is_owner = ?", true, true).map(&:account)
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
    self.respondent_template && consequence_ladder?
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = name.downcase.gsub(/[^a-z0-9]/i, '_')
  end

end
