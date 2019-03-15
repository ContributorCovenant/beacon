require 'gitlab'

class GitlabImportService

  attr_reader :account, :organization

  def initialize(account, organization)
    @account = account
    @organization = organization
  end

  def import_projects
    starting_count = organization.projects.count

    repositories.each do |repository|
      next unless repository_is_in_org?(repository)
      next if Project.find_by(name: [repository.name, repository.name.titleize])

      project = Project.create!(
        name: repository.name.titleize,
        url: repository.web_url,
        description: "",
        account_id: organization.account_id,
        coc_url: organization.coc_url || "",
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
    @client ||= Gitlab.client(
      endpoint: "https://gitlab.com/api/v4/",
      private_token: account.gitlab_token
    )
  end

  def repositories
    client.projects(membership: true)
  end

  def repository_is_in_org?(repository)
    repository.namespace.full_path == organization.remote_org_name
  end

end
