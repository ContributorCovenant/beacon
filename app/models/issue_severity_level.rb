class IssueSeverityLevel < ApplicationRecord

  belongs_to :project
  has_many :issues

  default_scope { order("severity ASC") }

  validates_presence_of :scope, :label, :severity, :example, :consequence
  validates_uniqueness_of :severity, scope: :project

  SCOPES = %w{project organization example}.freeze

end