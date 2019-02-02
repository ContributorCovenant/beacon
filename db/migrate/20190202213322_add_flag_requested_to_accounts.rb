class AddFlagRequestedToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :flag_requested, :boolean, default: false
    add_column :accounts, :flag_requested_reason, :text
  end
end
