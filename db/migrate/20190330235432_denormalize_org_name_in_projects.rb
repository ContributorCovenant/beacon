class DenormalizeOrgNameInProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :organization_name, :string
    add_index :projects, :name
    add_index :projects, :organization_name
  end
end
