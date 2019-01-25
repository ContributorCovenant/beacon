class ProjectConfirmationService

  attr_reader :project

  def self.confirm!(project)
    new(project: project).confirm!
  end

  def initialize(project:)
    @project = project
  end

  def confirm!
    return false unless confirm_via_oauth || confirm_via_token
    project.update_attribute(:confirmed_at, DateTime.now)
  end

  private

  # TODO: Use oauth to link account to GitHub or GitLab account and confirm project ownership
  def confirm_via_oauth
    true
  end

  # TODO: Visit project's confirmation_token_url to confirm project ownership
  def confirm_via_token
    true
  end

end
