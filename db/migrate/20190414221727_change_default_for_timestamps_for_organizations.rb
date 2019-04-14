class ChangeDefaultForTimestampsForOrganizations < ActiveRecord::Migration[5.2]
  def change
    change_column_default :organizations, :created_at, from: "2019-04-13 00:00:00", to: nil
    change_column_default :organizations, :updated_at, from: "2019-04-13 00:00:00", to: nil
  end
end
