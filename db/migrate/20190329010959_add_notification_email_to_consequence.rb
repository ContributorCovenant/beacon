class AddNotificationEmailToConsequence < ActiveRecord::Migration[5.2]
  def change
    add_column :consequences, :email_to_notify, :string
  end
end
