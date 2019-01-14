# frozen_string_literal: true

class ProjectSetting < ApplicationRecord
  belongs_to :project

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
