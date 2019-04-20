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

    describe "process incoming issue" do
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

    describe "process followup messages" do
      let!(:issue) { FactoryBot.create(:issue, project_id: project.id, issue_number: 101) }

      context "no attachment" do
        let(:email_comment) { FactoryBot.build(:email, :response_to_issue) }

        before do
          EmailProcessorService.new(email_comment).process
        end

        it "updates an issue" do
          expect(issue.issue_comments.count).to eq(1)
        end
      end

      context "with attachment" do
        let(:email_comment) { FactoryBot.build(:email, :response_to_issue, :with_valid_attachment) }

        before do
          EmailProcessorService.new(email_comment).process
        end

        it "updates an issue" do
          expect(issue.issue_comments.count).to eq(1)
        end

        it "creates an attachment" do
          expect(issue.reload.uploads.size).to eq(1)
        end

      end

    end

    context "with attachments" do

      context "valid image attachment" do
        let(:email_issue) { FactoryBot.build(:email, :with_valid_attachment) }
        let(:service) { EmailProcessorService.new(email_issue) }

        it "creates file attachments" do
          expect{ service.process }.to_not raise_error
          issue = project.issues.last
          expect(issue.uploads.size).to eq(1)
        end
      end

      context "invalid attachment" do
        let(:email_issue) { FactoryBot.build(:email, :with_invalid_attachment) }
        let(:service) { EmailProcessorService.new(email_issue) }
        it "does not file attachments" do
          expect{ service.process }.to_not raise_error
          issue = project.issues.last
          expect(issue.uploads.size).to eq(0)
        end
      end

      context "valid and invalid attachment" do
        let(:email_issue) { FactoryBot.build(:email, :with_valid_and_invalid_attachments) }
        let(:service) { EmailProcessorService.new(email_issue) }

        it "creates only valid file attachments" do
          expect{ service.process }.to_not raise_error
          issue = project.issues.last
          expect(issue.uploads.size).to eq(1)
        end
      end

    end

    describe "process incoming issue comment" do

      let!(:issue) {
        Issue.create!(
          project_id: project.id,
          reporter_id: moderator.id,
          description: "Something"
        )
      }
      let(:email_comment) {
        FactoryBot.build(
          :email,
          subject: "Beacon: Sample Project Issue ##{issue.issue_number}",
          body: "This is a comment"
        )
      }

      before do
        EmailProcessorService.new(email_comment).process
      end

      it "creates a reporter comment" do
        expect(project.issues.last.issue_comments.last.text).to eq("This is a comment")
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
