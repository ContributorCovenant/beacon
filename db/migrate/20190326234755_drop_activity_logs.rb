class DropActivityLogs < ActiveRecord::Migration[5.2]
  def change
    drop_table :activity_logs do
    end
  end
end
