class CreateCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :credentials, id: :uuid do |t|
      t.string :provider
      t.string :uid
      t.string :email
      t.references :account, type: :uuid, foreign_key: true
    end
    add_index :credentials, [:provider, :uid], unique: true
  end
end
