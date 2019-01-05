class CreateIssueEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_events, id: :uuid do |t|
      t.string :event
      t.string :actor_encrypted_id
      t.references :issue, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
