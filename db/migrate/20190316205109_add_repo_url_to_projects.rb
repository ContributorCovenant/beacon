class AddRepoUrlToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :repo_url, :string
  end
end
