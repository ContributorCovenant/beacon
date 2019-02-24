class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.references :organization, type: :uuid, foreign_key: true
      t.references :project, type: :uuid, foreign_key: true
      t.boolean :is_owner, default: false
      t.boolean :is_default_moderator, default: false
      t.boolean :can_manage_org, default: false
      t.boolean :can_create_org_projects, default: false
      t.boolean :can_see_historic_issues, default: true
      t.timestamps
    end
  end
end
