class Autoresponder < ApplicationRecord

  belongs_to :project, optional: true
  belongs_to :organization, optional: true

  validates_presence_of :text

  attr_accessor :default_source

  def populate_from(issue_url, project_url)
    text.gsub!("[[PROJECT_NAME]]", project.name)
    text.gsub!("[[CODE_OF_CONDUCT_URL]]", project.coc_url)
    text.gsub!("[[ISSUE_URL]]", issue_url)
    text.gsub!("[[PROJECT_URL]]", project_url)
    return text
  end
end
