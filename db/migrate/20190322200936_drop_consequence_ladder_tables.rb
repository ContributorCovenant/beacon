class DropConsequenceLadderTables < ActiveRecord::Migration[5.2]
  def change
    remove_column :issues, :issue_severity_level_id
    drop_table :issue_severity_levels
  end
end
