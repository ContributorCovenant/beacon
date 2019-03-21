class Organization < ApplicationRecord
  validates_uniqueness_of :name
  validates_uniqueness_of :slug
  validates_presence_of :name

  belongs_to :account
  has_one :consequence_guide, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :issue_severity_levels, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_one :respondent_template, dependent: :destroy

  before_create :set_slug

  attr_accessor :consequence_ladder_default_source

  def consequence_ladder?
    issue_severity_levels.any?
  end

  def flag!(reason)
    self.update_attributes(
      is_flagged: true,
      flagged_reason: reason,
      flagged_at: Time.zone.now
    )
    projects.each { |project| project.flag!("Organization flagged") }
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

  def toggle_flagged
    self.update_attribute(:is_flagged, !is_flagged)
  end

  def to_param
    slug
  end

  private

  def set_slug
    self.slug = name.downcase.gsub(/[^a-z0-9]/i, '_')
  end

end
