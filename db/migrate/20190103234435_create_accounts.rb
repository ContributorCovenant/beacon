class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false, default: ""
      t.string :email, null: false, default: ""
      t.string :temp_2fa_code
      t.boolean :email_confirmed
      t.timestamps
    end
  end
end
