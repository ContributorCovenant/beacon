class CreateActivityLog < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_logs, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.string :label, null: false
      t.timestamps
    end
  end
end
