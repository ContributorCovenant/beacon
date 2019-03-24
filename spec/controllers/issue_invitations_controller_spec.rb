require 'rails_helper'

RSpec.describe IssueInvitationsController, type: :controller do

  describe "#create" do

    let(:moderator)   { FactoryBot.create(:kate) }
    let(:respondent)  { FactoryBot.create(:exene) }
    let(:rando)       { FactoryBot.create(:donnie) }
    let(:project)     { FactoryBot.create(:project, account: moderator) }
    let(:issue)       { Issue.new(id: SecureRandom.uuid, issue_number: 1) }

    before do
      RespondentTemplate.create(project: project, text: "foo")
      allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
      allow(Project).to receive(:find_by).and_return(project)
      allow(Issue).to receive(:find).and_return(issue)
      allow(issue).to receive(:project).and_return(project)
      allow(issue).to receive(:set_issue_number)
      Role.create!(account_id: moderator.id, project_id: project.id, is_owner: true)
    end

    context "permissions" do

      it "allows a moderator to invite a respondent" do
        controller.sign_in(moderator, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_invitation: { email: respondent.email, summary: "You're invited!" }
        }
        expect(response).to have_http_status 302
      end

      it "blocks an unaffiliated account from inviting a respondent" do
        controller.sign_in(rando, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_invitation: { email: respondent.email, summary: "I'm trying to invite you..." }
        }
        expect(response).to have_http_status 403
      end

    end

    context "validation" do

      it "fails with a missing summary" do
        controller.sign_in(moderator, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_invitation: { email: respondent.email, summary: "" }
        }
        expect(response).to have_http_status 204
      end

      it "fails with a missing respondent email" do
        controller.sign_in(moderator, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_invitation: { email: nil, summary: "You're invited!" }
        }
        expect(response).to have_http_status 204
      end

    end

  end

end
