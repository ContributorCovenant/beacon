class CreateIssueSeverityLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_severity_levels, id: :uuid do |t|
      t.string :scope, null: false, default: 'project'
      t.string :label, null: false
      t.integer :severity, null: false
      t.text :example, null: false
      t.text :consequence, null: false
      t.references :project, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
