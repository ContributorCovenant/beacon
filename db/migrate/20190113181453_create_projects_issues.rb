class CreateProjectsIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :project_issues, id: :uuid do |t|
      t.references :project, type: :uuid, foreign_key: true
      t.string :issue_encrypted_id, null: false
      t.timestamps
    end
  end
end
