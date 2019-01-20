class CreateAccountProjectBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :account_project_blocks, id: :uuid do |t|
      t.references :project, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true
      t.text :reason
      t.timestamps
    end
  end
end
