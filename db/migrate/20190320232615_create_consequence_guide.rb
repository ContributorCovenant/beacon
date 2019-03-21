class CreateConsequenceGuide < ActiveRecord::Migration[5.2]
  def change
    create_table :consequence_guides, id: :uuid do |t|
      t.references :organization, type: :uuid, foreign_key: true
      t.references :project, type: :uuid, foreign_key: true
      t.string :scope, default: "template"
    end
  end
end
