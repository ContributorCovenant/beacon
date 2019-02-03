class RespondentTemplate < ApplicationRecord

  belongs_to :project, optional: true

  validates_presence_of :text

  attr_accessor :respondent_template_default_source

  def self.beacon_default
    find_by(is_beacon_default: true)
  end

  def populate_from(issue, issue_url)
    severity = project.issue_severity_levels.find_by(severity: issue.issue_severity_level)

    text.gsub!("[[PROJECT_NAME]]", project.name)
    text.gsub!("[[CODE_OF_CONDUCT_URL]]", project.coc_url)
    text.gsub!("[[VIOLATION_EXAMPLE]]", severity.example)
    text.gsub!("[[CONSEQUENCE]]", severity.consequence)
    text.gsub!("[[ISSUE_URL]]", issue_url)

    return text
  end

end
