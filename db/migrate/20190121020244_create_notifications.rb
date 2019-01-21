class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :project, type: :uuid, foreign_key: true
      t.references :issue, type: :uuid, foreign_key: true
      t.references :issue_comment, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
