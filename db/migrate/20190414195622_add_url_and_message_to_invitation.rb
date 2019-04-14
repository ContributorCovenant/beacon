class AddUrlAndMessageToInvitation < ActiveRecord::Migration[5.2]
  def change
    add_column :invitations, :message, :text
  end
end
