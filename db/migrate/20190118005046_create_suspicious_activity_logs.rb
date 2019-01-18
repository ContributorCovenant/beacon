class CreateSuspiciousActivityLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :suspicious_activity_logs, id: :uuid do |t|
      t.string :controller
      t.string :action
      t.string :ip_address
      t.text :params
      t.references :account, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
