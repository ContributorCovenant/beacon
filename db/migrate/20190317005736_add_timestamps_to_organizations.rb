class AddTimestampsToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :created_at, :datetime, default: Date.today
    add_column :organizations, :updated_at, :datetime, default: Date.today
  end
end
