class CreateUserActivityLog < ActiveRecord::Migration[5.2]
  def change
    create_table :account_activity_logs, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.integer :issues_opened, default: 0
      t.integer :issues_dismissed, default: 0
      t.integer :issues_marked_spam, default: 0
      t.integer :times_blocked, default: 0
      t.integer :times_flagged, default: 0
      t.integer :projects_created, default: 0
      t.integer :password_resets, default: 0
      t.integer :recaptcha_failures, default: 0
      t.integer :four_o_fours, default: 0
      t.timestamps
    end
  end
end
