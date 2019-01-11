# frozen_string_literal: true

class CreateIssueComments < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_comments, id: :uuid do |t|
      t.text :text
      t.string :commenter_encrypted_id
      t.boolean :visible_to_reporter, default: false
      t.references :issue, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
