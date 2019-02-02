module Permissions

  def can_access_abuse_reports?
    !!is_admin
  end

  def can_access_admin_dashboard?
    !!is_admin
  end

  def can_access_admin_account_dashboard?
    !!is_admin
  end

  def can_access_admin_project_dashboard?
    !!is_admin
  end

  def can_lock_project?
    !!is_admin
  end

  def can_block_account?(project)
    return true if project.moderators.include?(self)
    false
  end

  def can_comment_on_issue?(issue)
    return true if issue.project.moderators.include?(self)
    return true if issue.reporter == self && !blocked_from_project?(issue.project)
    return true if issue.respondent == self && !blocked_from_project?(issue.project)
    false
  end

  def can_create_project?
    !is_flagged
  end

  def can_invite_respondent?(issue)
    issue.project.moderator?(self)
  end

  def can_manage_consequence_ladder?(project)
    project.moderator?(self)
  end

  def can_manage_respondent_template?(project)
    project.moderator?(self)
  end

  def can_moderate_project?(project)
    project.moderator?(self)
  end

  def can_manage_project?(project)
    project.account == self
  end

  def can_open_issue_on_project?(project)
    return false unless project.accepting_issues?
    return false if blocked_from_project?(project)
    return false if is_flagged
    return false if total_issues_past_24_hours >= Setting.throttling(:max_issues_per_day)
    return false if project.issue_count_from_past_24_hours == project.project_setting.rate_per_day
    return true
  end

  def can_report_abuse?(project)
    return false if is_flagged
    return false if abuse_reports.submitted.select{ |report| report.project == project }.any?
    return false if abuse_reports.submitted.count >= Setting.throttling(:max_abuse_reports_per_day)
    true
  end

  def can_upload_images_to_issue?(issue)
    issue.reporter == self
  end

  def can_view_issue?(issue)
    return true if issue.project.moderator?(self)
    return true if issue.reporter == self && !blocked_from_project?(issue.project)
    return true if issue.respondent == self && !blocked_from_project?(issue.project)
    false
  end

end
