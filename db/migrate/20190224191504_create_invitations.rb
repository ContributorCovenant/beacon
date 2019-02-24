class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.references :project, type: :uuid, foreign_key: true
      t.references :organization, type: :uuid, foreign_key: true
      t.string :email
      t.boolean :is_owner, default: false
      t.timestamps
    end
  end
end
