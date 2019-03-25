class Autoresponder < ApplicationRecord

  belongs_to :project, optional: true
  belongs_to :organization, optional: true

  validates_presence_of :text

  before_save :update_org_projects

  attr_accessor :default_source

  def populate_from(issue_url, project_url)
    text.gsub!("[[PROJECT_NAME]]", project.name)
    text.gsub!("[[CODE_OF_CONDUCT_URL]]", project.coc_url)
    text.gsub!("[[ISSUE_URL]]", issue_url)
    text.gsub!("[[PROJECT_URL]]", project_url)
    return text
  end

  private

  def update_org_projects
    return unless organization
    previous_text = changes[:text][0]
    organization.projects.includes(:autoresponder).map(&:autoresponder).each do |autoresponder|
      next unless autoresponder.text == previous_text # project has modified it
      autoresponder.update_attribute(:text, changes[:text][1])
    end
  end

end
