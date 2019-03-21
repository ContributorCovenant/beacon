class CreateConsequence < ActiveRecord::Migration[5.2]
  def change
    create_table :consequences, id: :uuid do |t|
      t.references :consequence_guide, type: :uuid, foreign_key: true
      t.integer :severity, null: false
      t.string :label, null: false
      t.text :action, null: false
      t.text :consequence, null: false
      t.timestamps
    end
  end
end
