require 'octokit'

class GithubImportService

  attr_reader :access_token, :account, :organization

  def initialize(account, organization)
    @account = account
    @organization = organization
  end

  def import_projects
    raise "you are not a member of this GitHub organization" unless verify_membership

    starting_count = organization.projects.count

    repositories.each do |repository|
      next if Project.find_by(name: [repository.name, repository.name.titleize])
      coc_url = organization.coc_url.present? && organization.coc_url || repository.code_of_conduct&.html_url || ""
      project = Project.create!(
        name: repository.name.titleize,
        url: repository.html_url,
        description: repository.description || "",
        account_id: organization.account_id,
        coc_url: coc_url,
        organization_id: organization.id,
        confirmed_at: DateTime.now,
        public: true
      )
      IssueSeverityLevel.clone_from_org_template_for_project(project) if organization.issue_severity_levels.any?
      if respondent_template = organization.respondent_template
        RespondentTemplate.create(
          project_id: project.id,
          text: respondent_template.text
        )
      end
      project.project_setting.touch
      project.check_setup_complete?
    end
    return { success: true, count: organization.projects.count - starting_count }
  rescue StandardError => e
    return { success: false, error: e }
  end

  private

  def client
    @client ||= Octokit::Client.new(access_token: account.github_token)
  end

  def uid
    @credentials ||= account.credentials.find_by(provider: "github")
    @uid ||= @credentials.uid.to_i
  end

  def repositories
    client.organization_repositories(
      organization.remote_org_name,
      accept: "application/vnd.github.scarlet-witch-preview+json"
    )
  end

  def verify_membership
    return false unless uid
    return client.organization_members(organization.remote_org_name).map(&:id).include?(uid)
  end

end
