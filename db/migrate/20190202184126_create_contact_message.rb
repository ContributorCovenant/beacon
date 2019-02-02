class CreateContactMessage < ActiveRecord::Migration[5.2]
  def change
    create_table :contact_messages, id: :uuid do |t|
      t.text :message
      t.text :sender_ip
      t.string :sender_email
      t.timestamps
    end
  end
end
