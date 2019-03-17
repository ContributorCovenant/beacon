class CreateSurvey < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys, id: :uuid do |t|
      t.references :project, type: :uuid, foreign_key: true
      t.string :issue_encrypted_id
      t.string :account_encrypted_id
      t.boolean :fairness
      t.boolean :responsiveness
      t.boolean :sensitivity
      t.boolean :community
      t.integer :would_recommend
      t.text :recommendation_note
      t.timestamps
    end
  end
end
