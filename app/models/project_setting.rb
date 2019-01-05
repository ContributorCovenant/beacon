class ProjectSetting < ApplicationRecord

  belongs_to :project

  def pause!
    update_attribute(:paused_at, Time.zone.now)
  end

  def unpause!
    update_attribute(:paused_at, nil)
  end

  def paused?
    !!self.paused_at
  end

end
