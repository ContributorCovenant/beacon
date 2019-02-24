class AddOrganizationIdToRespondentTemplates < ActiveRecord::Migration[5.2]
  def change
    add_reference :respondent_templates, :organization, type: :uuid, index: true
  end
end
