class Issue < ApplicationRecord

  include AASM

  attr_accessor :account_id, :project_id

  has_many :issue_events
  has_many :issue_comments

  before_create :set_issue_number
  after_create :set_reporter_encrypted_id
  after_create :set_project_encrypted_id

  OPEN_STATUSES = %w{submitted acknowledged reopened}.freeze

  aasm do
    state :submitted, initial: true
    state :acknowledged, before_enter: Proc.new{ |args| log_event(args) }
    state :dismissed, before_enter: Proc.new{ |args| log_event(args) }
    state :resolved, before_enter: Proc.new{ |args| log_event(args) }
    state :reopened, before_enter: Proc.new{ |args| log_event(args) }

    event :acknowledge do
      transitions from: :submitted, to: :acknowledged
    end

    event :dismiss do
      transitions from: [:acknowledged, :reopened], to: :dismissed
    end

    event :resolve do
      transitions from: [:acknowledged, :reopened], to: :resolved
    end

    event :reopen do
      transitions from: [:dismissed, :resolved], to: :reopened
    end
  end

  def open?
    OPEN_STATUSES.include?(self.aasm_state)
  end

  def project
    @project ||= Project.find(EncryptionService.decrypt(self.project_encrypted_id))
  end

  def reporter
    @reporter ||= Account.find(EncryptionService.decrypt(self.reporter_encrypted_id))
  end

  def respondent
    return unless self.respondent_encrypted_id

    @respondent ||= Account.find(EncryptionService.decrypt(self.respondent_encrypted_id))
  end

  private

  def set_issue_number
    result = Issue.connection.execute("SELECT nextval('issues_issue_number_seq')")
    self.issue_number = result[0]['nextval']
  end

  def set_reporter_encrypted_id
    update_attribute(:reporter_encrypted_id, EncryptionService.encrypt(self.account_id))
    AccountIssue.create(account_id: self.account_id, issue_id: self.id)
  end

  def set_project_encrypted_id
    update_attribute(:project_encrypted_id, EncryptionService.encrypt(self.project_id))
    ProjectIssue.create(project_id: self.project_id, issue_id: self.id)
  end

  def log_event(args)
    IssueEvent.create(
      issue_id: self.id,
      actor_id: args[:account_id],
      event: "Status changed to #{aasm.to_state}"
    )
  end

end
