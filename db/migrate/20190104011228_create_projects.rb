# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :name, null: false, unique: true
      t.string :slug, null: false
      t.string :url, null: false, unique: true
      t.string :coc_url, null: false
      t.text :description, null: false
      t.references :account, type: :uuid, foreign_key: true
      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end
