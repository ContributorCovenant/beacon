class AddIsExternalReporterToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :is_external_reporter, :boolean, default: false
  end
end
