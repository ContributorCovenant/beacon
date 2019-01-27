class AddAdminFlagToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :is_admin, :boolean, default: false
  end
end
