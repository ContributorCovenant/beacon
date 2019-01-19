class AddResolutionNoteToIssue < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :resolution_text, :text
    add_column :issues, :resolved_at, :datetime
  end
end
