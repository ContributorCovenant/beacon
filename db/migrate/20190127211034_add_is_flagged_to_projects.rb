class AddIsFlaggedToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :is_flagged, :boolean, default: false
    add_column :projects, :flagged_reason, :text
    add_column :projects, :flagged_at, :datetime
  end
end
