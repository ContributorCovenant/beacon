module Permissions

  def can_comment_on_issue?(issue)
    return true if issue.project.moderators.include?(self)
    return true if issue.reporter == self
    return true if issue.respondent == self
    false
  end

  def can_create_project?
    true
  end

  def can_invite_respondent?(issue)
    issue.project.moderator?(self)
  end

  def can_manage_consequence_ladder?(project)
    project.moderator?(self)
  end

  def can_moderate_project?(project)
    project.moderator?(self)
  end

  def can_manage_project?(project)
    project.account == self
  end

  def can_open_issue_on_project?(project)
    project.accepting_issues?
  end

  def can_view_issue?(issue)
    return true if issue.project.moderator?(self)
    return true if issue.reporter == self
    return true if issue.respondent == self
    false
  end

end
