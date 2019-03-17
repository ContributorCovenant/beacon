class AddIsFlaggedToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :is_flagged, :boolean, default: false
  end
end
