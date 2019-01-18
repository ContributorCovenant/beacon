# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssueCommentsController, type: :controller do

  describe "#create" do

    let(:reporter)    { FactoryBot.create(:account, email: "reporter@example.com") }
    let(:moderator)   { FactoryBot.create(:account, email: "moderator@example.com") }
    let(:respondent)  { FactoryBot.create(:account, email: "respondent@example.com") }
    let(:rando)       { FactoryBot.create(:account, email: "rando@example.com") }
    let(:project)     { FactoryBot.create(:project, account: moderator) }
    let(:issue)       { FactoryBot.create(:issue, project_id: project.id, reporter_id: reporter.id) }

    before do
      allow(Project).to receive(:find_by).and_return(project)
      allow(Issue).to receive(:find).and_return(issue)
      allow(issue).to receive(:project).and_return(project)
      allow(issue).to receive(:reporter).and_return(reporter)
      allow(issue).to receive(:respondent).and_return(respondent)
    end

    context "permissions" do

      it "allows a moderator to make a comment" do
        controller.sign_in(moderator, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_comment: { text: "This sure is a comment." }
        }
        expect(response).to have_http_status 302
      end

      it "allows a reporter to make a comment" do
        controller.sign_in(reporter, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_comment: { text: "This sure is a comment." }
        }
        expect(response).to have_http_status 302
      end

      it "allows a respondent to make a comment" do
        controller.sign_in(respondent)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_comment: { text: "This sure is a comment." }
        }
        expect(response).to have_http_status 302
      end

      it "blocks an unaffiliated account from making a comment" do
        controller.sign_in(rando, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue_id: 1,
          issue_comment: { text: "This sure is a comment." }
        }
        expect(response).to have_http_status 403
      end

    end
  end

end
