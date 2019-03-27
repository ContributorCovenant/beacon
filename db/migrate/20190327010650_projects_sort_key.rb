class ProjectsSortKey < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :sort_key, :string, default: ""
    add_index :projects, :sort_key
  end
end
