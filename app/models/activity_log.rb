class ActivityLog

  def self.log(account_id:, label:)
    ActivityLog.create(account_id: account_id, label: label)
  end

end
