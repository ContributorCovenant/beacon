class CreateReporterAutoresponder < ActiveRecord::Migration[5.2]
  def change
    create_table :autoresponders, id: :uuid do |t|
      t.references :project, type: :uuid, foreign_key: true
      t.references :organization, type: :uuid, foreign_key: true
      t.string :scope
      t.text :text
      t.timestamps
    end
  end
end
