class AddNormalizedEmailIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :accounts, :normalized_email, unique: true
  end
end

