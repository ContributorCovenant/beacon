require 'rails_helper'

RSpec.describe TransparencyReportingService do

  let(:maintainer) { FactoryBot.create(:kate) }
  let(:reporter) { FactoryBot.create(:ricky) }
  let(:respondent) { FactoryBot.create(:bobby) }
  let(:project) { FactoryBot.create(:project, account: maintainer) }
  let!(:issue) {
    FactoryBot.create(
      :issue,
      project_id: project.id,
      reporter_id: reporter.id,
      created_at: Date.today - 7.days,
      aasm_state: "resolved",
      closed_at: Date.today
    )
  }
  let!(:another_issue) {
    FactoryBot.create(
      :issue,
      project_id: project.id,
      reporter_id: reporter.id,
      created_at: Date.today - 7.days,
      aasm_state: "resolved",
      closed_at: Date.today
    )
  }
  let!(:survey_good) {
    Survey.create(
      project_id: project.id,
      issue_id: issue.id,
      account_id: reporter.id,
      kind: "reporter",
      would_recommend: 9,
      fairness: true,
      responsiveness: true,
      sensitivity: false,
      community: true
    )
  }
  let!(:survey_bad) {
    Survey.create(
      project_id: project.id,
      issue_id: another_issue.id,
      account_id: reporter.id,
      kind: "reporter",
      would_recommend: 5,
      fairness: false,
      responsiveness: true,
      sensitivity: false,
      community: true
    )
  }
  let(:service) { TransparencyReportingService.new(project) }

  it "calculates average time to resolution" do
    expect(service.average_time_to_resolution).to eq(7)
  end

  it "calculates net promoter score" do
    expect(service.net_promoter_score).to eq("Poor")
  end

  it "calculates health" do
    expect(service.health).to eq("Good")
  end

  it "determines if enough data is present to be public" do
    expect(service.suitable_for_public?).to be_truthy
  end

  it "returns labelled scores" do
    expect(service.labelled_scores[:fairness]).to eq("Good")
  end

end
