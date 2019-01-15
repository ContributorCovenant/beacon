class AddVisibleToRespondentToIssueComments < ActiveRecord::Migration[5.2]
  def change
    change_table :issue_comments do |t|
      t.boolean :visible_to_respondent, default: false
    end
  end
end
