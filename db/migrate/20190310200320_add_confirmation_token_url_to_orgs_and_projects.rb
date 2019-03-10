class AddConfirmationTokenUrlToOrgsAndProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :confirmation_token_url, :string
  end
end
