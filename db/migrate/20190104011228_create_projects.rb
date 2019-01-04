class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false, unique: true
      t.string :slug, null: false
      t.string :url, null: false, unique: true
      t.string :coc_url, null: false
      t.text :description, null: false
      t.references :account
      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end
