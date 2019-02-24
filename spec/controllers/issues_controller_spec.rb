require 'rails_helper'

RSpec.describe IssuesController, type: :controller do

  describe "#create" do

    let(:moderator)   { FactoryBot.create(:danielle) }
    let(:reporter)    { FactoryBot.build(:exene) }
    let!(:project)    { FactoryBot.create(:project, account: moderator) }

    before do
      allow_any_instance_of(Issue).to receive(:set_issue_number)
      Role.create(account_id: moderator.id, project_id: project.id, is_owner: true)
    end

    context "when a project is not accepting new issues" do

      before do
        allow_any_instance_of(Project).to receive(:accepting_issues?).and_return(false)
      end

      it "does not allow an issue to be opened" do
        controller.sign_in(reporter, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue: { description: "My CoC issue description" }
        }
        expect(response).to have_http_status 403
      end

    end

    context "when a project is accepting new issues" do

      before do
        allow_any_instance_of(Project).to receive(:accepting_issues?).and_return(true)
        allow(NotificationService).to receive(:notify)
      end

      it "allows an issue to be opened" do
        controller.sign_in(reporter, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue: { description: "My CoC issue description" }
        }
        expect(response).to have_http_status 302
      end

      it "notifies project moderators" do
        controller.sign_in(reporter, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue: { description: "My CoC issue description" }
        }
        expect(NotificationService).to have_received(:notify).with(
          account: moderator,
          project_id: project.id,
          issue_id: Issue.last.id
        )
      end

    end

    context "status changes" do

      before do
        allow(IssueNotificationsMailer).to receive(:notify_on_status_change)
      end

      describe "#acknowledge" do

        let(:issue) { FactoryBot.create(:issue, project_id: project.id, aasm_state: "submitted") }

        before do
          allow_any_instance_of(Issue).to receive(:reporter).and_return(reporter)
        end

        it "updates the issue's status" do
          controller.sign_in(moderator, scope: :account)
          post :acknowledge, params: {
            project_slug: project.slug,
            issue_id: issue.id
          }
          expect(issue.reload.aasm_state).to eq("acknowledged")
        end

      end

      describe "#dismiss" do

        let(:issue) { FactoryBot.create(:issue, project_id: project.id, aasm_state: "acknowledged") }

        before do
          allow_any_instance_of(Issue).to receive(:reporter).and_return(reporter)
        end

        it "updates the issue's status" do
          controller.sign_in(moderator, scope: :account)
          post :dismiss, params: {
            project_slug: project.slug,
            issue_id: issue.id
          }
          expect(issue.reload.aasm_state).to eq("dismissed")
        end

      end

      describe "#resolve" do

        let(:issue) { FactoryBot.create(:issue, project_id: project.id, aasm_state: "acknowledged") }

        before do
          allow_any_instance_of(Issue).to receive(:reporter).and_return(reporter)
        end

        it "updates the issue's status" do
          controller.sign_in(moderator, scope: :account)
          post :resolve, params: {
            project_slug: project.slug,
            issue_id: issue.id,
            issue: { resolution_text: "We dealt with it, effectively." }
          }
          expect(issue.reload.aasm_state).to eq("resolved")
        end

      end

      describe "#reopen" do

        let(:issue) { FactoryBot.create(:issue, project_id: project.id, aasm_state: "dismissed") }

        before do
          allow_any_instance_of(Issue).to receive(:reporter).and_return(reporter)
        end

        it "updates the issue's status" do
          controller.sign_in(moderator, scope: :account)
          post :reopen, params: {
            project_slug: project.slug,
            issue_id: issue.id
          }
          expect(issue.reload.aasm_state).to eq("reopened")
        end

      end

    end

  end

end
