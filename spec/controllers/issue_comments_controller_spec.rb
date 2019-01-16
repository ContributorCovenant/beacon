# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IssueCommentsController, type: :controller do

  describe "#create" do

    let(:reporter)    { Account.new(confirmed_at: Time.zone.now) }
    let(:moderator)   { Account.new(confirmed_at: Time.zone.now) }
    let(:respondent)  { Account.new(confirmed_at: Time.zone.now) }
    let(:rando)       { Account.new(confirmed_at: Time.zone.now) }
    let(:project)     { Project.new(id: SecureRandom.uuid, slug: "sample-project", account: moderator) }
    let(:issue)       { Issue.new(id: SecureRandom.uuid) }

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
