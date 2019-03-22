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

  def can_access_admin_organization_dashboard?
    !!is_admin
  end

  def can_access_admin_project_dashboard?
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

  def can_complete_survey_on_issue?(issue, project)
    return false unless issue.respondent == self || issue.reporter == self
    return !project.surveys.select{ |s| s.issue == issue }.map(&:account).find{ |account| account == self }.present?
  end

  def can_invite_respondent?(issue)
    issue.project.moderator?(self)
  end

  def can_lock_account?
    !!is_admin
  end

  def can_lock_organization?
    !!is_admin
  end

  def can_lock_project?
    !!is_admin
  end

  def can_manage_project_consequence_guide?(project)
    return false unless project.present?
    project.moderator?(self)
  end

  def can_manage_project_respondent_template?(project)
    project.moderator?(self)
  end

  def can_manage_organization_consequence_guide?(organization)
    return false unless organization.present?
    organization.owner?(self)
  end

  def can_manage_organization_respondent_template?(organization)
    organization.owner?(self)
  end

  def can_moderate_project?(project)
    project.moderator?(self)
  end

  def can_view_organization?(organization)
    organization.owners.include? self
  end

  def can_manage_organization?(organization)
    return false unless organization
    organization.owners.include? self
  end

  def can_manage_project?(project)
    project.owners.include? self
  end

  def can_open_issue_on_project?(project)
    return false unless project.accepting_issues?
    return false if project.require_3rd_party_auth? && !third_party_credentials?
    return false if blocked_from_project?(project)
    return false if is_flagged
    return false if project.issue_count_from_past_24_hours == project.project_setting.rate_per_day
    return false if issues.submitted.past_24_hours.count == Setting.throttling(:max_issues_per_day)
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
    return true if is_admin?
    return true if issue.project.moderator?(self)
    return true if issue.reporter == self && !blocked_from_project?(issue.project)
    return true if issue.respondent == self && !blocked_from_project?(issue.project)
    false
  end

  def can_view_survey_on_issue?(project)
    return true if is_admin?
    return true if project.moderators.include?(self)
    false
  end

end
