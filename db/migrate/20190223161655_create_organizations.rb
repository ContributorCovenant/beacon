class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name
      t.string :url
      t.string :coc_url
      t.string :slug
      t.text :description
      t.references :account, type: :uuid, foreign_key: true
      t.datetime :flagged_at
      t.text :flagged_reason
      t.datetime :confirmed_at
    end
  end
end
