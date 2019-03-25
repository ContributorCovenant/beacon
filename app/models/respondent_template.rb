class RespondentTemplate < ApplicationRecord

  belongs_to :project, optional: true
  belongs_to :organization, optional: true

  validates_presence_of :text

  before_save :update_org_projects

  attr_accessor :respondent_template_default_source

  def self.beacon_default
    find_by(is_beacon_default: true)
  end

  def populate_from(issue, issue_url)
    text.gsub!("[[PROJECT_NAME]]", project.name)
    text.gsub!("[[CODE_OF_CONDUCT_URL]]", project.coc_url)
    text.gsub!("[[ISSUE_URL]]", issue_url)

    if consequence = issue.consequence
      text.gsub!("[[VIOLATION_EXAMPLE]]", consequence.action)
      text.gsub!("[[CONSEQUENCE]]", consequence.consequence)
    end

    return text
  end

  private

  def update_org_projects
    return unless organization
    previous_text = changes[:text][0]
    organization.projects.includes(:respondent_template).map(&:respondent_template).each do |template|
      next unless template
      next unless template.text == previous_text # project has modified it
      template.update_attribute(:text, changes[:text][1])
    end
  end

end
