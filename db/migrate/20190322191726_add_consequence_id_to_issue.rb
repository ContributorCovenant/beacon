class AddConsequenceIdToIssue < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :consequence_id, :uuid
  end
end
