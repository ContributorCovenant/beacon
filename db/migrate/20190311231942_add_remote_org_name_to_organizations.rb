class AddRemoteOrgNameToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :remote_org_name, :string
  end
end
