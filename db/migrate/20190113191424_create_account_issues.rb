class CreateAccountIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :account_issues, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.string :issue_encrypted_id, null: false
      t.timestamps
    end
  end
end
