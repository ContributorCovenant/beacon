class CreateProjectSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :project_settings, id: :uuid do |t|
      t.datetime :paused_at
      t.integer :rate_per_day, default: 5
      t.boolean :require_3rd_party_auth, default: false
      t.integer :minimum_3rd_party_auth_age_in_days, default: 30
      t.boolean :allow_anonymous_issues, default: false
      t.boolean :publish_stats, default: true
      t.boolean :include_in_directory, default: true
      t.references :project
      t.timestamps
    end
  end
end
