class CreateRespondentTemplate < ActiveRecord::Migration[5.2]
  def change
    create_table :respondent_templates, id: :uuid do |t|
      t.references :project, type: :uuid, foreign_key: true
      t.text       :text
      t.boolean    :is_beacon_default, default: false
      t.timestamps
    end
  end
end
