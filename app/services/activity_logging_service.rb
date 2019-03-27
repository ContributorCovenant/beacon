class ActivityLoggingService

  ACTIVITIES = [
    :issues_opened,
    :issues_dismissed,
    :issues_marked_spam,
    :times_blocked,
    :times_flagged,
    :issues_dismissed,
    :projects_created,
    :password_resets,
    :recaptcha_failures,
    :four_o_fours
  ].freeze

  def self.log(account, action)
    return unless account
    return unless ACTIVITIES.include?(action)
    log = account.account_activity_log || AccountActivityLog.create(account_id: account.id)
    previous_count = log.send(action)
    log.update_attribute(action, previous_count + 1)
  end

end
