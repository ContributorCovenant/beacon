class AddTokenToCredentials < ActiveRecord::Migration[5.2]
  def change
    add_column :credentials, :token_encrypted, :string
  end
end
