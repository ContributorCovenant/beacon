class AddNotificationIdsToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :notification_encrypted_ids, :string, array: true, default: []
    remove_column :notifications, :account_id
  end
end
