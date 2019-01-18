class AddEncryptedIssueIdsToAccount < ActiveRecord::Migration[5.2]
  def change
    change_table :accounts do |t|
      t.text :issues_encrypted_ids, default: [], array: true
    end
  end
end
