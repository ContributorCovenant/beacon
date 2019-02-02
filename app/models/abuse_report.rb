class AbuseReport < ApplicationRecord

  include AASM

  belongs_to :account
  has_one :abuse_report_subject, dependent: :destroy

  before_create :set_report_number
  after_create :save_associated_subject

  validates_presence_of :description

  attr_accessor :flag

  aasm do
    state :submitted, initial: true
    state :dismissed
    state :resolved

    event :dismiss do
      transitions from: [:submitted], to: :dismissed
    end

    event :resolve do
      transitions from: [:submitted], to: :resolved
    end

  end

  def reporter
    self.account
  end

  def project=(project)
    build_abuse_report_subject(project_id: project.id)
  end

  def project
    @project ||= abuse_report_subject.project
  end

  def reportee=(account)
    build_abuse_report_subject(account_id: account.id)
  end

  def reportee
    @reportee ||= abuse_report_subject.account
  end

  def issue
    @issue ||= abuse_report_subject.issue
  end

  def kind
    return "Project" if project
    return "Individual" if reportee
    return "Issue" if issue
  end

  private

  def save_associated_subject
    self.abuse_report_subject.save
  end

  def set_report_number
    return if self.report_number
    result = AbuseReport.connection.execute("SELECT nextval('abuse_reports_report_number_seq')")
    self.report_number = result[0]['nextval']
  end

end
