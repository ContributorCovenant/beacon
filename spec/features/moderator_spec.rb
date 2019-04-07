require "rails_helper"

describe "moderation", type: :feature do

  let(:moderator) { FactoryBot.create(:danielle) }
  let!(:reporter) { FactoryBot.create(:exene) }
  let!(:project)  { FactoryBot.create(:project, account: moderator, public: true) }
  let!(:issue)    { FactoryBot.create(:issue, reporter_id: reporter.id, project_id: project.id) }
  let!(:issue_comment) do
    IssueComment.create!(
      commenter_id: reporter.id,
      issue_id: issue.id,
      visible_to_reporter: true,
      context: "reporter",
      text: "One other thing that occurs to me..."
    )
  end

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    Role.create(account_id: moderator.id, project_id: project.id, is_owner: true)
    login_as(moderator, scope: :account)
  end

  context "notifications" do

    before do
      NotificationService.notify(
        account_id: moderator.id,
        project_id: project.id,
        issue_id: issue.id,
        issue_comment_id: nil
      )
      NotificationService.notify(
        account_id: moderator.id,
        project_id: project.id,
        issue_id: issue.id,
        issue_comment_id: issue_comment.id
      )
      moderator.reload
    end

    it "indicates in the main navigation that there is a new issue in a project" do
      visit root_path
      expect(page).to have_content("My Projects 2")
    end

    it "displays an issue count on the My Projects page" do
      visit root_path
      click_on "My Projects"
      expect(page).to have_content("#{project.name} 2")
      expect(page).to have_content("Issues: 1 New")
    end

    it "displays an issue count on the project details page" do
      visit projects_path
      click_on project.name
      expect(page).to have_content("New Issues 1")
    end

    it "displays a message count on the issue details page" do
      visit projects_path
      visit projects_path
      click_on project.name
      click_on issue.issue_number
      expect(page).to have_content("Reporter Talk 1")
    end

  end

  context "issue details" do

    before do
      visit projects_path
      click_on project.name
      click_on issue.issue_number
    end

    it "shows the reporter's name or email" do
      expect(page).to have_content(reporter.email)
    end

    it "shows the status of the issue" do
      expect(page).to have_content("Submitted")
    end

    it "shows the history of the issue" do
      click_on "Acknowledge"
      click_on "Issue History"
      expect(page).to have_content("Submitted by #{reporter.email}")
      expect(page).to have_content("Status changed to acknowledged by #{moderator.email}")
    end

  end

  context "issue lifecycle" do

    before do
      Consequence.create(
        consequence_guide_id: project.consequence_guide.id,
        severity: 1,
        label: "Correction",
        action: "Use of inappropriate language, such as profanity, or other behavior deemed unprofessional.",
        consequence: "A private, written warning from a moderator, with clarity of violation and explanatione."
      )
      Consequence.create(
        consequence_guide_id: project.consequence_guide.id,
        severity: 2,
        label: "Warning",
        action: "A violation through a single incident or series of actions that create toxicity.",
        consequence: "A warning with consequences of continued behavior."
      )
      visit projects_path
      click_on project.name
      click_on issue.issue_number
    end

    it "allows a moderator to assign a severity" do
      select "1: Correction", from: "issue_consequence_id"
      click_on "Save"
      expect(page).to have_content("1 (Correction)")
    end

    it "allows a moderator to acknowledge an issue" do
      click_on "Acknowledge"
      expect(page).to have_content("Acknowledged")
      expect(page).to have_content("Status changed to acknowledged by #{moderator.email}")
      click_on "Issue History"
    end

    it "allows a moderator to resolve an issue" do
      click_on "Acknowledge"
      click_on "Resolution"
      fill_in "issue_resolution_text", with: "I spoke to the respondent and they are going to edit their comment."
      click_on "Resolve Issue"
      expect(page).to have_content("Resolved")
    end

    it "allows a moderator to dismiss an issue" do
      click_on "Acknowledge"
      click_on "Resolution"
      fill_in "issue_resolution_text", with: "I spoke to the respondent and they are going to edit their comment."
      click_on "Dismiss"
      expect(page).to have_content("Dismissed")
    end

    it "allows a moderator to reopen an issue" do
      click_on "Acknowledge"
      click_on "Resolution"
      fill_in "issue_resolution_text", with: "I spoke to the respondent and they are going to edit their comment."
      click_on "Resolve Issue"
      click_on "Re-Open"
      expect(page).to have_content("Reopened")
    end
  end

  context "moderator discussions" do
    before do
      visit projects_path
      click_on project.name
      click_on issue.issue_number
    end

    it "allows the moderator to send a message to other moderators" do
      click_on "Moderator Talk"
      within("#nav-internal-discussion") do
        fill_in("issue_comment_text", with: "Sarah, what do you think?")
      end
      click_on "Send to Moderators"
      expect(page).to have_content("Sarah")
    end

  end

  context "reporter interactions" do

    before do
      visit projects_path
      click_on project.name
      click_on issue.issue_number
    end

    it "allows a moderator to block a reporter" do
      click_on "Details"
      expect(page).to have_content("Reporter Profile")
      fill_in "account_project_block_reason", with: "This person is harassing us!"
      click_on "Block"
      expect(page).to have_content("This account is blocked")
    end

    it "allows the moderator to send a message to a reporter" do
      click_on "Reporter Talk"
      within("#nav-reporter-discussion") do
        fill_in("issue_comment_text", with: "Can you provide some more details?")
      end
      click_on "Send to Reporter"
      expect(page).to have_content("Can you provide")
    end

    it "allows the moderator to see details about the reporter" do
      click_on "Details"
      expect(page).to have_content("Reporter Profile for #{reporter.email}")
      expect(page).to have_content("Issue ##{issue.issue_number}")
    end

    it "allows the moderator to block the reporter" do
      click_on "Details"
      fill_in "account_project_block_reason", with: "This person is trolling."
      click_on "Block"
      expect(page).to have_content("This account is blocked from this project")
    end
  end

  context "respondent interactions" do

    let(:respondent) { FactoryBot.create(:ricky) }

    before do
      RespondentTemplate.create(
        project_id: project.id,
        text: "This is to inform you that you have been named as a respondent on a code of conduct issue."
      )
      visit projects_path
      click_on project.name
      click_on issue.issue_number
    end

    it "allows the moderator to assign a respondent" do
      click_on "Add Respondent"
      fill_in("issue_invitation_email", with: respondent.email)
      fill_in("issue_invitation_summary", with: "I need to talk to you about something.")
      click_on "Send"
      expect(page).to have_content(respondent.email)
      expect(page).to have_content("The respondent has been notified and invited to comment on this issue.")
    end

    context "with respondent assigned" do

      before do
        click_on "Add Respondent"
        fill_in("issue_invitation_email", with: respondent.email)
        fill_in("issue_invitation_summary", with: "I need to talk to you about something.")
        click_on "Send"
      end

      it "allows the moderator to send a message to a respondent" do
        click_on "Respondent Talk"
        within("#nav-respondent-discussion") do
          fill_in("issue_comment_text", with: "When are you free to discuss this?")
        end
        click_on "Send to Respondent"
        expect(page).to have_content("When are you free")
      end

      it "allows the moderator to see details about the respondent" do
        within("#respondent-details") do
          click_on "Details"
        end
        expect(page).to have_content("Respondent Profile for #{respondent.email}")
        expect(page).to have_content("Issue ##{issue.issue_number}")
      end

      it "allows the moderator to block the respondent" do
        within("#respondent-details") do
          click_on "Details"
        end
        fill_in "account_project_block_reason", with: "This person is a repeat offender."
        click_on "Block"
        expect(page).to have_content("This account is blocked from this project")
      end
    end
  end

  context "owners and moderators" do

    before do
      allow_any_instance_of(InvitationsController).to receive(:verify_recaptcha).and_return(true)
    end

    let(:new_moderator) { FactoryBot.create(:kate) }

    it "lets a user invite a moderator" do
      login_as(moderator, scope: :account)
      visit project_path(project)
      click_on "Moderators"
      fill_in "invitation_email", with: new_moderator.email
      click_on "Invite Moderator"
      expect(page).to have_content("Moderators Awaiting Confirmation")
      expect(new_moderator.invitations.count > 0).to be_truthy
    end

    it "lets a user invite a co-owner" do
      login_as(moderator, scope: :account)
      visit project_path(project)
      click_on "Moderators"
      fill_in "invitation_email", with: new_moderator.email
      check "invitation_is_owner"
      click_on "Invite Moderator"
      expect(page).to have_content("Moderators Awaiting Confirmation")
      expect(new_moderator.invitations.count > 0).to be_truthy
    end

    it "lets an invited moderator join a project" do
      Invitation.create(account: new_moderator, project: project, email: new_moderator.email)
      login_as(new_moderator, scope: :account)
      visit invitations_path
      click_on "Accept"
      expect(page).to have_content("You have accepted the invitation")
      expect(page).to have_content(project.name)
      expect(project.moderator?(new_moderator)).to be_truthy
    end

    it "lets an invited owner join a project" do
      Invitation.create(account: new_moderator, project: project, email: new_moderator.email, is_owner: true)
      login_as(new_moderator, scope: :account)
      visit invitations_path
      click_on "Accept"
      expect(page).to have_content("You have accepted the invitation")
      expect(page).to have_content(project.name)
      expect(project.owner?(new_moderator)).to be_truthy
    end

  end

end
