class AddConfirmedAtToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :confirmed_at, :datetime
  end
end
