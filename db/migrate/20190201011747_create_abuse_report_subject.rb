class CreateAbuseReportSubject < ActiveRecord::Migration[5.2]
  def change
    create_table :abuse_report_subjects, id: :uuid do |t|
      t.references :abuse_report, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true
      t.references :project, type: :uuid, foreign_key: true
      t.references :issue, type: :uuid, foreign_key: true
    end
  end
end
