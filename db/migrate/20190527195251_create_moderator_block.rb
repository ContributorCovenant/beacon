class CreateModeratorBlock < ActiveRecord::Migration[5.2]
  def change
    create_table :moderator_blocks, id: :uuid do |t|
      t.references :issue, type: :uuid, foreign_key: true
      t.references :account, type: :uuid, foreign_key: true
    end
  end
end
