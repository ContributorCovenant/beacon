class AccountProjectBlock < ApplicationRecord
  belongs_to :project
  belongs_to :account

  attr_accessor :report_for_abuse

  def issues
    project_issues = project.issues
    project_issues.select do |issue|
      issue.reporter == account || issue.respondent == account
    end
  end

end
