class FixConsequenceGuideScope < ActiveRecord::Migration[5.2]
  def change
    change_column :consequence_guides, :scope, :string, default: nil
  end
end
