class DeviseAuthyAddToAccounts < ActiveRecord::Migration[5.2]
  def self.up
    change_table :accounts do |t|
      t.string    :authy_id
      t.datetime  :last_sign_in_with_authy
      t.boolean   :authy_enabled, :default => false
    end

    add_index :accounts, :authy_id
  end

  def self.down
    change_table :accounts do |t|
      t.remove :authy_id, :last_sign_in_with_authy, :authy_enabled
    end
  end
end

