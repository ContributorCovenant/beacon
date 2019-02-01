class AbuseReportSubject < ApplicationRecord

  belongs_to :account, optional: true
  belongs_to :project, optional: true
  belongs_to :issue, optional: true

end
