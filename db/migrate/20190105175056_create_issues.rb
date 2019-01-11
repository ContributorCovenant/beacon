# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[5.2]
  def up
    create_table :issues, id: :uuid do |t|
      t.text :description
      t.string :reporter_encrypted_id
      t.integer :issue_number
      t.string :project_encrypted_id
      t.string :aasm_state
      t.text :urls, default: [], array: true
      t.boolean :is_spam, default: false
      t.boolean :is_abusive, default: false
      t.datetime :acknowledged_at
      t.datetime :closed_at
      t.timestamps
    end
    execute 'CREATE SEQUENCE issues_issue_number_seq START 101'
  end

  def down
    drop_table :issues
    execute 'DROP SEQUENCE issues_issue_number_seq'
  end
end
