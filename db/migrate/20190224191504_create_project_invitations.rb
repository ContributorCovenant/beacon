class CreateProjectInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :project_invitations, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.references :project, type: :uuid, foreign_key: true
      t.string :email
      t.timestamps
    end
  end
end
