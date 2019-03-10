class AddPhoneNumberToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :phone_encrypted, :string
    add_column :accounts, :send_sms_on_issue_open, :boolean, default: false
  end
end
