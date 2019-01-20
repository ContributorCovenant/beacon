class AddSetupStatesToProject < ActiveRecord::Migration[5.2]
  def change
    change_table :projects do |t|
      t.boolean :has_confirmed_settings, default: false
    end

  end
end
