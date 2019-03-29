class AddReporterConsequenceToIssue < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :reporter_consequence_id, :uuid
    add_foreign_key :issues, :consequences, column: :reporter_consequence_id
  end
end
