require 'gitlab'

class GitlabImportService

  attr_reader :account, :organization

  def initialize(account, organization)
    @account = account
    @organization = organization
  end

  def import_projects
    starting_count = organization.projects.count
    errors = ""
    repositories.each do |repository|
      next unless repository_is_in_org?(repository)
      next if Project.find_by(name: [repository.name, repository.name.titleize])

      coc_url = organization.coc_url.present? && organization.coc_url
      coc_url ||= coc_url(repository)

      begin
        project = Project.create!(
          name: repository.name.titleize,
          url: repository.web_url,
          description: repository.description || repository.name.titleize,
          account_id: organization.account_id,
          coc_url: coc_url,
          organization_id: organization.id,
          confirmed_at: DateTime.now,
          public: true,
          accept_issues_by_email: organization.accept_issues_by_email
        )
      rescue StandardError => e
        errors << "#{repository.name}: #{e.message}."
        next
      end

      project.consequence_guide.clone_from(organization) if organization.consequence_guide.consequences.any?

      if respondent_template = organization.respondent_template
        RespondentTemplate.create(
          project_id: project.id,
          text: respondent_template.text
        )
      end

      if autoresponder = organization.autoresponder
        Autoresponder.create(
          project_id: project.id,
          text: autoresponder.text
        )
      end

      project.project_setting.touch
      project.check_setup_complete?
    end
    return { success: true, count: organization.reload.projects.count - starting_count, error: errors }
  end

  private

  def client
    @client ||= Gitlab.client(
      endpoint: "https://gitlab.com/api/v4/",
      private_token: account.gitlab_token
    )
  end

  def coc_url(repository)
    client.file_contents(repository.id, "CODE_OF_CONDUCT.md")
    repository.readme_url.gsub("README", "CODE_OF_CONDUCT")
  rescue GitLab::Error::NotFound
    ""
  end

  def repositories
    client.projects(membership: true)
  end

  def repository_is_in_org?(repository)
    repository.namespace.full_path == organization.remote_org_name
  end

end
