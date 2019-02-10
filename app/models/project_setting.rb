class ProjectSetting < ApplicationRecord

  belongs_to :project

  def toggle_pause
    paused? ? unpause! : pause!
  end

  def include_in_directory=(value)
    project.update_attribute(:public, value)
  end

  def include_in_directory
    project.public?
  end

  def pause!
    update_attribute(:paused_at, Time.zone.now)
  end

  def unpause!
    update_attribute(:paused_at, nil)
  end

  def paused?
    !!paused_at
  end
end
