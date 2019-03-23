class AddFlaggedReasonToOrganization < ActiveRecord::Migration[5.2]
  def change
    return if Organization.new.respond_to?(:flagged_reason)
    add_column :organizations, :flagged_reason, :text
  end
end
