class AddEventFieldsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :is_event, :boolean, default: false
    add_column :projects, :start_date, :datetime
    add_column :projects, :duration, :integer
    add_column :projects, :frequency, :string
    add_column :projects, :attendees, :integer
  end
end
