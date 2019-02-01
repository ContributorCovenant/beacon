class AddIsFlaggedToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :is_flagged, :boolean, default: false
    add_column :accounts, :flagged_reason, :text
    add_column :accounts, :flagged_at, :datetime
  end
end
