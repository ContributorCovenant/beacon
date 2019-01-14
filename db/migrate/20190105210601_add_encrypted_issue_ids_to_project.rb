# frozen_string_literal: true

class AddEncryptedIssueIdsToProject < ActiveRecord::Migration[5.2]
  def change
    change_table :projects do |t|
      t.text :issues_encrypted_ids, default: [], array: true
    end
  end
end
