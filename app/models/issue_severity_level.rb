class IssueSeverityLevel < ApplicationRecord

  belongs_to :organization, optional: true
  belongs_to :project, optional: true
  has_many :issues

  default_scope { order("severity ASC") }
  scope :beacon_defaults, -> { where(scope: "template") }

  validates_presence_of :scope, :label, :severity, :example, :consequence

  def self.clone_from_template_for_organization(organization)
    organization.issue_severity_levels.destroy_all
    beacon_defaults.each do |default|
      organization.issue_severity_levels.create(
        severity: default.severity,
        label: default.label,
        example: default.example,
        consequence: default.consequence
      )
    end
  end

  def self.clone_from_template_for_project(project)
    project.issues.each{ |issue| issue.update_attribute(:issue_severity_level_id, nil) }
    project.issue_severity_levels.destroy_all
    beacon_defaults.each do |default|
      project.issue_severity_levels.create(
        severity: default.severity,
        label: default.label,
        example: default.example,
        consequence: default.consequence
      )
    end
  end

  def self.clone_from_existing_project(source:, target:)
    target.issues.each{ |issue| issue.update_attribute(:issue_severity_level_id, nil) }
    target.issue_severity_levels.destroy_all
    source.issue_severity_levels.each do |default|
      target.issue_severity_levels.create(
        severity: default.severity,
        label: default.label,
        example: default.example,
        consequence: default.consequence
      )
    end
  end

  def can_be_safely_destroyed?
    return true if organization
    return false if project.issues.where(issue_severity_level_id: self.id).any?
    true
  end

end
