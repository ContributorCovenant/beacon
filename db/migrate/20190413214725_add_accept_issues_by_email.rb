class AddAcceptIssuesByEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :accept_issues_by_email, :boolean, default: false
    add_column :projects, :accept_issues_by_email, :boolean, default: false
  end
end
