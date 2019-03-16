class ProjectConfirmationService

  attr_reader :project, :credential, :method

  def self.confirm!(project, credential, method)
    new(project, credential, method).confirm!
  end

  def initialize(project, credential, method)
    @project = project
    @method = method
    @credential = credential
  end

  def confirm!
    if method == "github" || method == "gitlab"
      confirmed = confirm_via_oauth
    else
      confirmed = confirm_via_token
    end
    return false unless confirmed
    project.update_attribute(:confirmed_at, DateTime.now)
  end

  private

  def confirm_via_oauth
    if method == "github"
      return false unless repo = github_client.search_repositories(project.repo_name)
      !!repo.fork?
    elsif method == "gitlab"
      return false unless repo = gitlab_client.project(project.repo_name)
      !repo.respond_to?(:forked_from_project)
    end
  rescue StandardError => e
    Rails.logger.info("Unable to verify via oauth for #{project.name}: #{e}")
    false
  end

  def confirm_via_token
    return true unless Rails.env.production?
    token = URI.parse(project.confirmation_token_url).read.chomp
    token =~ /#{project.confirmation_token}/
  rescue StandardError => e
    Rails.logger.info("Unable to verify token for #{project.name}: #{e}")
    false
  end

  def github_client
    Octokit::Client.new(access_token: credential.token)
  end

  def gitlab_client
    Gitlab.client(
      endpoint: "https://gitlab.com/api/v4/",
      private_token: credential.token
    )
  end

end
