class AddShowModeratorsToProjectSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :project_settings, :show_moderator_names, :boolean, default: false
  end
end
