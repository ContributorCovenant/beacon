# frozen_string_literal: true

class AddRespondentSummaryToIssues < ActiveRecord::Migration[5.2]
  def change
    change_table :issues do |t|
      t.text :respondent_summary
    end
  end
end
