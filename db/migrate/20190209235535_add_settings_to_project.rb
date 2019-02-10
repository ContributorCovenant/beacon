class AddSettingsToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :public, :boolean, default: false
    add_column :projects, :setup_complete, :boolean, default: false
    remove_column :project_settings, :include_in_directory
  end
end
