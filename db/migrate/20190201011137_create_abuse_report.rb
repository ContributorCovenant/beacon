class CreateAbuseReport < ActiveRecord::Migration[5.2]
  def up
    create_table :abuse_reports, id: :uuid do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.text       :description
      t.string     :aasm_state
      t.integer    :report_number
      t.text       :admin_note
      t.timestamps
    end
    execute 'CREATE SEQUENCE abuse_reports_report_number_seq START 101'
  end

  def down
    drop_table :abuse_reports
    execute 'DROP SEQUENCE abuse_reports_report_number_seq'
  end
end
