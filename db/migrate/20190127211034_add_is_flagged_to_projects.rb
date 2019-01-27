class AddIsFlaggedToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :is_flagged, :boolean, default: false
  end
end
