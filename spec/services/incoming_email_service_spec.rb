require 'rails_helper'

describe IncomingEmailService do

  let(:moderator) { FactoryBot.create(:kate) }
  let(:reporter) { FactoryBot.create(:exene) }
  let(:email_issue) { FactoryBot.build(:email) }

  describe "#process" do

    context "project accepting email issues" do
      let!(:project) {
        FactoryBot.create(
          :project,
          account_id: moderator.id,
          name: "Sample Project",
          accept_issues_by_email: true
        )
      }
      describe "processing an incoming issue" do
        it "creates an account" do
          IncomingEmailService.new(email_issue).process
          expect(Account.find_by(email: "reporter@foo.com")).to_not be_nil
        end
        it "creates an issue" do
          IncomingEmailService.new(email_issue).process
          expect(project.issues.last.description).to eq("Something bad happened to me.")
        end
        it "notifies moderators of a new issue" do
          expect_any_instance_of(IncomingEmailService).to receive(:notify_moderators_of_new_issue)
          IncomingEmailService.new(email_issue).process
        end
      end

      context "with attachments" do
        context "valid image attachment" do
          let(:email_issue) { FactoryBot.build(:email, :with_valid_attachment) }
          let(:service) { IncomingEmailService.new(email_issue) }

          it "creates file attachments" do
            expect{ service.process }.to_not raise_error
            issue = project.issues.last
            expect(issue.uploads.size).to eq(1)
          end
        end

        context "invalid attachment" do
          let(:email_issue) { FactoryBot.build(:email, :with_invalid_attachment) }
          let(:service) { IncomingEmailService.new(email_issue) }
          it "does not file attachments" do
            expect{ service.process }.to_not raise_error
            issue = project.issues.last
            expect(issue.uploads.size).to eq(0)
          end
        end

        context "valid and invalid attachment" do
          let(:email_issue) { FactoryBot.build(:email, :with_valid_and_invalid_attachments) }
          let(:service) { IncomingEmailService.new(email_issue) }

          it "creates only valid file attachments" do
            expect{ service.process }.to_not raise_error
            issue = project.issues.last
            expect(issue.uploads.size).to eq(1)
          end
        end
      end
    end

    context "project not accepting issues" do

      let!(:project) {
        FactoryBot.create(
          :project,
          account_id: moderator.id,
          name: "Sample Project",
          accept_issues_by_email: false
        )
      }
      before do
        IncomingEmailService.new(email_issue).process
      end

      it "doesn't create an account" do
        expect(Account.find_by(email: "reporter@foo.com")).to be_nil
      end

      it "doesn't create an issue" do
        expect(project.issues.count).to eq(0)
      end
    end

    describe "processing issue comments" do
      let!(:project) {
        FactoryBot.create(
          :project,
          account_id: moderator.id,
          name: "Sample Project",
          accept_issues_by_email: true
        )
      }
      let!(:issue) { FactoryBot.create(:issue, reporter_id: reporter.id, project_id: project.id, issue_number: 101) }
      let(:email_comment) {
        FactoryBot.build(
          :email,
          subject: "Beacon: Sample Project Issue ##{issue.issue_number}",
          body: "This is a comment",
          from: {
            token: reporter.email.split("@")[0],
            host: reporter.email.split("@")[1],
            email: reporter.email
          }
        )
      }

      it "creates a reporter comment" do
        IncomingEmailService.new(email_comment).process
        expect(issue.issue_comments.count).to eq(1)
        expect(project.issues.last.issue_comments.last.text).to eq("This is a comment")
      end

      it "notifies moderators of a new comment" do
        expect_any_instance_of(IncomingEmailService).to receive(:notify_moderators_of_new_comment)
        IncomingEmailService.new(email_comment).process
      end

      context "with attachment" do
        let(:email_comment) {
          FactoryBot.build(
            :email, :response_to_issue, :with_valid_attachment,
            subject: "Beacon: Sample Project Issue ##{issue.issue_number}",
            body: "This is a comment",
            from: {
              token: reporter.email.split("@")[0],
              host: reporter.email.split("@")[1],
              email: reporter.email
            }
          )
        }

        before do
          IncomingEmailService.new(email_comment).process
        end

        it "creates an attachment" do
          expect(issue.reload.uploads.size).to eq(1)
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
          IncomingEmailService.new(email_issue).process
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

end
