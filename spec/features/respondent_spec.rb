require "rails_helper"

describe "the respondent experience", type: :feature do

  let(:maintainer)  { FactoryBot.create(:danielle) }
  let!(:project)    { FactoryBot.create(:project, account: maintainer, public: true) }
  let!(:reporter)   { FactoryBot.create(:ricky) }
  let!(:respondent) { FactoryBot.create(:bobby) }
  let!(:issue)      { FactoryBot.create(:issue, reporter_id: reporter.id, project_id: project.id) }

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    AccountIssue.create(issue_id: issue.id, account: respondent)
    allow_any_instance_of(Issue).to receive(:respondent).and_return(respondent)
  end

  it "enables a respondent to sign in" do
    visit new_account_session_path
    fill_in "Email", with: respondent.email
    fill_in "Password", with: respondent.password
    click_button "Sign In"
    expect(page).to have_content "Signed in successfully."
  end

  context "notifications" do

    before do
      login_as(respondent, scope: :account)
    end

    context "issue-level" do

      before do
        NotificationService.notify(
          account: respondent,
          project: project,
          issue_id: issue.id,
          issue_comment_id: nil
        )
      end

      it "indicates in the main navigation that there is an issue" do
        visit root_path
        expect(page).to have_content("My Issues 1")
      end
    end

    context "conversation-level" do

      let!(:issue_comment) do
        IssueComment.create!(
          commenter_id: maintainer.id,
          issue_id: issue.id,
          visible_to_respondent: true,
          context: "respondent",
          text: "Are you open to discussing how to prevent this from happening again?"
        )
      end

      before do
        NotificationService.notify(
          account: respondent,
          project: project,
          issue_id: issue.id,
          issue_comment_id: issue_comment.id
        )
      end

      it "indicates in the main navigation that there is a new message" do
        visit root_path
        expect(page).to have_content("My Issues 1")
      end

      it "indicates in Manage My Issues that there is a new message" do
        visit root_path
        click_on "My Issues"
        expect(page).to have_content("Issue ##{issue.issue_number} 1")
      end
    end
  end

  context "moderator interactions" do

    let!(:issue_comment) do
      IssueComment.create!(
        commenter_id: maintainer.id,
        issue_id: issue.id,
        visible_to_respondent: true,
        context: "respondent",
        text: "Are you open to discussing how to prevent this from happening again?"
      )
    end

    before do
      login_as(respondent, scope: :account)
      visit project_issue_path(project, issue)
    end

    it "allows the respondent to message moderators" do
      fill_in("issue_comment_text", with: "Can you give me a link to the PR?")
      click_on("Send Message")
      expect(page).to have_content("a link to the PR")
    end

    it "shows messages from the moderators" do
      expect(page).to have_content("discussing how to prevent this")
    end

  end

end
