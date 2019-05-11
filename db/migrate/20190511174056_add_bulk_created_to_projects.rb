class AddBulkCreatedToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :bulk_created, :boolean, default: false
  end
end
