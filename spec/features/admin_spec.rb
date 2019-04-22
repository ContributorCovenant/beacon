require "rails_helper"

describe "Admins", type: :feature do

  let!(:admin) { FactoryBot.create(:admin) }
  let!(:maintainer) { FactoryBot.create(:danielle) }
  let!(:bad_actor) { FactoryBot.create(:donnie) }
  let!(:project) { FactoryBot.create(:project, account: maintainer, public: true) }

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    Role.create(account_id: maintainer.id, project_id: project.id, is_owner: true)
    login_as(admin, scope: :account)
  end

  describe "managing abuse reports" do

    let!(:abuse_report) {
      AbuseReport.create(
        account: maintainer,
        reportee: bad_actor,
        description: "Repeated offenses"
      )
    }

    before do
      visit admin_abuse_reports_path
    end

    it "can view a list of abuse reports" do
      expect(page).to have_content(bad_actor.email)
    end

    it "can view an individual abuse report" do
      click_on(abuse_report.report_number)
      expect(page).to have_content("Repeated offenses")
    end

    it "can dismiss a report" do
      click_on(abuse_report.report_number)
      fill_in "abuse_report_admin_note", with: "This seems excessive."
      click_on "Dismiss Report"
      expect(page).to have_content("Dismissed")
    end

    it "can resolve a report" do
      click_on(abuse_report.report_number)
      fill_in "abuse_report_admin_note", with: "What a jerk."
      click_on "Lock Account"
      expect(page).to have_content("Resolved")
      expect(bad_actor.reload.is_flagged).to be_truthy
    end
  end

  describe "managing accounts" do

    before do
      visit admin_accounts_path
    end

    it "can view all accounts" do
      expect(page).to have_content(maintainer.email)
      expect(page).to have_content(bad_actor.email)
    end

    it "can view an account" do
      click_on bad_actor.email
      expect(page).to have_content(bad_actor.email)
      expect(page).to have_content("No tracked activity")
    end

  end

  describe "managing organizations" do

    let!(:organization) {
      Organization.create(
        name: "My Org",
        description: "The very best.",
        account: maintainer
      )
    }

    before do
      visit admin_organizations_path
    end

    it "can view all organizations" do
      expect(page).to have_content(organization.name)
    end

    it "can view an organization" do
      click_on organization.name
      expect(page).to have_content("The very best.")
    end

  end

  describe "managing projects" do

    before do
      visit admin_projects_path
    end

    it "can view all projects" do
      expect(page).to have_content(project.name)
    end

    it "can view an project" do
      click_on project.name
      expect(page).to have_content(project.description)
    end

  end

end
