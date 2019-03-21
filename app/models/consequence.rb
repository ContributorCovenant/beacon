class Consequence < ApplicationRecord

  belongs_to :consequence_guide

  validates_presence_of :label, :severity, :action, :consequence

end
