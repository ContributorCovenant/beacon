class AddKindToSurvey < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :kind, :string
  end
end
