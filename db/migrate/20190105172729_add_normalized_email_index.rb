class AddNormalizedEmailIndex < ActiveRecord::Migration[5.2]
  def up
    add_index :accounts, :normalized_email, unique: true
  end

  def down
    remove_index 'accounts', name: 'index_accounts_on_normalized_email'
  end
end
