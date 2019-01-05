class CreateIssues < ActiveRecord::Migration[5.2]
  def up
    create_table :issues, id: :uuid do |t|
      t.text :description
      t.string :reporter_encrypted_id
      t.integer :issue_number
      t.string :project_encrypted_id
      t.timestamps
    end
    execute "CREATE SEQUENCE issues_issue_number_seq START 1011"
  end

  def down
    drop_table :issues
    execute "DROP SEQUENCE issues_issue_number_seq"
  end

end
