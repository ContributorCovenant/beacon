class Consequence < ApplicationRecord

  belongs_to :consequence_guide

  validates_presence_of :label, :severity, :action, :consequence

  default_scope { order("severity ASC") }

  def can_be_safely_destroyed?
    !Issue.where(consequence_id: id).any?
  end

end
