class CreateIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :issues, id: :uuid do |t|
      t.text :description
      t.string :reporter_encrypted_id
      t.string :project_encrypted_id
      t.timestamps
    end
  end
end
