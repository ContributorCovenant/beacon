class AddIssueSeverityLevelToIssue < ActiveRecord::Migration[5.2]
  def change
    change_table :issues do |t|
      t.references :issue_severity_level, type: :uuid, foreign_key: true
    end
  end
end
