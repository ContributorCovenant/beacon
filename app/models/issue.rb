class Issue < ApplicationRecord

  attr_accessor :account_id, :project_id

  before_create :set_reporter_encrypted_id
  before_create :set_project_encrypted_id
  before_create  :set_issue_number

  def reporter
    @reporter ||= Account.find(EncryptionService.decrypt(self.reporter_encrypted_id))
  end

  def project
    @project ||= Project.find(EncryptionService.decrypt(self.project_encrypted_id))
  end

  private

  def set_issue_number
    result = Issue.connection.execute("SELECT nextval('issues_issue_number_seq')")
    self.issue_number = result[0]['nextval']
  end

  def set_reporter_encrypted_id
    self.reporter_encrypted_id = EncryptionService.encrypt(self.account_id)
  end

  def set_project_encrypted_id
    self.project_encrypted_id = EncryptionService.encrypt(self.project_id)
  end

end
