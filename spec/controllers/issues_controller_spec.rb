require 'rails_helper'

RSpec.describe IssuesController, type: :controller do

  describe "#create" do

    let(:moderator)   { FactoryBot.build(:account) }
    let(:reporter)    { FactoryBot.build(:account) }
    let!(:project)    { FactoryBot.create(:project, account: moderator) }

    before do
      allow_any_instance_of(Issue).to receive(:set_issue_number)
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
      end

      it "allows an issue to be opened" do
        controller.sign_in(reporter, scope: :account)
        post :create, params: {
          project_slug: project.slug,
          issue: { description: "My CoC issue description" }
        }
        expect(response).to have_http_status 302
      end

    end

  end

end
