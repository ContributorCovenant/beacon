class AddOrganizationIdToIssueSeverityLevels < ActiveRecord::Migration[5.2]
  def change
    add_reference :issue_severity_levels, :organization, type: :uuid, index: true
  end
end
