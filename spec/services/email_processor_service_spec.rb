require 'rails_helper'

describe EmailProcessorService do

  let(:moderator) { FactoryBot.create(:kate) }

  let(:email_issue) { FactoryBot.build(:email) }

  context "project accepting email issues" do

    let!(:project) {
      FactoryBot.create(
        :project,
        account_id: moderator.id,
        name: "Sample Project",
        accept_issues_by_email: true
      )
    }

    describe "process incoming email" do

      before do
        EmailProcessorService.new(email_issue).process
      end

      it "creates an account" do
        expect(Account.find_by(email: "reporter@foo.com")).to_not be_nil
      end

      it "creates an issue" do
        expect(project.issues.last.description).to eq("Something bad happened to me while contributing to sample_project.")
      end

    end
  end

  context "project not accepting email issues" do

    let!(:project) {
      FactoryBot.create(
        :project,
        account_id: moderator.id,
        name: "Sample Project",
        accept_issues_by_email: false
      )
    }

    describe "process incoming email" do

      before do
        ActionMailer::Base.deliveries = []
        EmailProcessorService.new(email_issue).process
      end

      it "does not creates an account" do
        expect(Account.find_by(email: "reporter@foo.com")).to be_nil
      end

      it "does not create an issue" do
        expect(project.issues.size).to eq(0)
      end

      it "notifies the sender that email issues are not accepted" do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end

    end
  end

end
