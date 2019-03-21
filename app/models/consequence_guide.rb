class ConsequenceGuide < ApplicationRecord

  belongs_to :organization, optional: true
  belongs_to :project, optional: true
  has_many :consequences, dependent: :destroy

  def self.clone_from_template_for_organization(organization)
    target = ConsequenceGuide.find_or_create_by(organization_id: organization.id)
    source = ConsequenceGuide.find_by(scope: "template")
    clone(target, source)
  end

  def self.clone_from_org_template_for_project(project)
    target = ConsequenceGuide.find_or_create_by(project_id: project.id)
    source = ConsequenceGuide.find_by(organization_id: project.organization_id)
    clone(target, source)
  end

  def self.clone_from_template_for_project(project)
    target = ConsequenceGuide.find_or_create_by(project_id: project.id)
    source = ConsequenceGuide.find_by(scope: "template")
    clone(target, source)
  end

  def self.clone_from_existing_project(source:, target:)
    target = ConsequenceGuide.find_or_create_by(project_id: target.id)
    source = ConsequenceGuide.find_by(project_id: source.id)
    clone(target, source)
  end

  def self.clone(target, source)
    target.consequences.destroy_all
    source.consequences.each do |consequence|
      Consequence.create(
        consequence_guide_id: target.id,
        severity: consequence.severity,
        label: consequence.label,
        action: consequence.example,
        consequence: consequence.consequence
      )
    end
  end

end
