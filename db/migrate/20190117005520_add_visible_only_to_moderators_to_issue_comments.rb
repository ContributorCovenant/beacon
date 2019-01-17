class AddVisibleOnlyToModeratorsToIssueComments < ActiveRecord::Migration[5.2]
  def change
    change_table :issue_comments do |t|
      t.boolean :visible_only_to_moderators, default: false
    end
  end
end
