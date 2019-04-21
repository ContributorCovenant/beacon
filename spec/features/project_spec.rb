require "rails_helper"

describe "The project setup process", type: :feature do

  let!(:maintainer)   { FactoryBot.create(:danielle) }
  let!(:moderator)   { FactoryBot.create(:peter) }
  let!(:project)      { FactoryBot.create(:project, account: maintainer, public: true) }

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    Role.create(account_id: maintainer.id, project_id: project.id, is_owner: true)
    Role.create(account_id: moderator.id, project_id: project.id, is_owner: false)
    Autoresponder.create(scope: "template", text: "Thank you for opening a code of conduct issue")
    login_as(maintainer, scope: :account)
  end

  context "without an organization" do

    before do
      guide = ConsequenceGuide.create(scope: "template")
      guide.consequences.create(
        severity: 1,
        label: "Correction",
        action: "Use of inappropriate language, such as profanity, or other behavior deemed unprofessional or unwelcome in the community.",
        consequence: "A private, written warning from a moderator, with clarity of violation and explanation of why the behavior was inappropriate."
      )
      RespondentTemplate.create(
        is_beacon_default: true,
        text: "This is to inform you that you have been named as a respondent on a code of conduct issue."
      )
    end

    it "lets a user create a project" do
      visit root_path
      click_on "My Projects"
      click_on("New Project")
      expect(page).to have_content("Register a Project")
      fill_in "project_name", with: "Contributor Covenant"
      fill_in "project_url", with: "https://github.com/contributorCovenant/contributor_covenant/"
      fill_in "project_coc_url", with: "https://github.com/contributorCovenant/contributor_covenant/CODE_OF_CONDUCT.md"
      fill_in "project_description", with: "The world's first code of conduct for OSS"
      click_on "Create Project"
      expect(page).to have_content("Contributor Covenant")
    end

    it "lets a moderator update a project" do
      visit root_path
      click_on "My Projects"
      click_on(project.name)
      click_on "Edit Project"
      fill_in "project_description", with: "A code of conduct for online communities"
      click_on "Update Project"
      expect(page).to have_content("A code of conduct for online communities")
    end

    it "lets a moderator pause a project" do
      visit root_path
      click_on "My Projects"
      click_on(project.name)
      click_on("Pause Issue Reporting")
      expect(project.reload.accepting_issues?).to be_falsey
    end

    it "lets a moderator update settings" do
      visit root_path
      click_on "My Projects"
      click_on(project.name)
      click_on("Project Settings")
      fill_in "project_setting_rate_per_day", with: "5"
      click_on("Update Settings")
      expect(project.reload.project_setting.rate_per_day).to eq(5)
    end

    it "lets a moderator confirm ownership" do
      visit root_path
      click_on "My Projects"
      click_on(project.name)
      click_on "Ownership Confirmation"
      click_on "Verify Ownership"
      expect(page).to have_content("√")
    end

    context "moderators" do
      before do
        visit root_path
        click_on "My Projects"
        click_on(project.name)
        click_on("Moderators")
      end

      it "displays existing moderators" do
        expect(page).to have_content(maintainer.email)
        expect(page).to have_content(moderator.email)
      end

      it "allows a moderator to be removed" do
        click_on "Remove"
        expect(page).to_not have_content(moderator.email)
      end

    end

    context "consequences guide" do

      before do
        visit root_path
        click_on "My Projects"
        click_on(project.name)
        click_on("Impact and Consequences")
      end

      it "can be cloned" do
        expect(page).to have_content("Clone from")
        select "Beacon Default", from: "consequence_guide_default_source"
        click_on("Clone")
        expect(page).to have_content("Correction")
      end

      it "can be created from scratch" do
        fill_in "consequence_label", with: "Disciplinary Action"
        select "2", from: "consequence_severity"
        fill_in "consequence_action", with: "Personal attacks"
        fill_in "consequence_consequence", with: "Reprimand from moderators"
        click_on("Update Guide")
        expect(page).to have_content("Personal attacks")
      end

      it "can get a new consequence" do
        fill_in "consequence_label", with: "Disciplinary Action"
        select "2", from: "consequence_severity"
        fill_in "consequence_action", with: "Personal attacks"
        fill_in "consequence_consequence", with: "Reprimand from moderators"
        click_on("Update Guide")
        expect(page).to have_content("Personal attacks")
      end

      it "can add a consequence" do
        fill_in "consequence_label", with: "Disciplinary Action"
        select "2", from: "consequence_severity"
        fill_in "consequence_action", with: "Personal attacks"
        fill_in "consequence_consequence", with: "Reprimand from moderators"
        click_on("Update Guide")
        expect(page).to have_content("Personal attacks")
      end
    end

    context "respondent template" do
      before do
        visit root_path
        click_on "My Projects"
        click_on(project.name)
        click_on("Respondent Template")
      end

      it "lets a moderator clone a respondent template" do
        expect(page).to have_content("Clone from")
        select "Beacon Default", from: "respondent_template_respondent_template_default_source"
        click_on("Clone")
        expect(page).to have_content("This is to inform you")
        fill_in "respondent_template_text", with: "We are sad to inform you"
        click_on("Save")
        expect(page).to have_content("You have successfully updated the respondent template.")
      end

      it "lets a moderator create a respondent template" do
        expect(page).to have_content("Clone from")
        fill_in "respondent_template_text", with: "We are sad to inform you"
        click_on("Save")
        expect(page).to have_content("You have successfully created a respondent template.")
      end
    end

    it "lets a user add an autoresponder" do
      visit root_path
      click_on "My Projects"
      click_on(project.name)
      click_on("Autoresponder")
      expect(page).to have_content("Clone from")
      select "Beacon Default", from: "autoresponder_default_source"
      click_on("Clone")
      expect(page).to have_content("Thank you for opening")
      click_on("Edit")
      fill_in "autoresponder_text", with: "Thanks so much"
      click_on("Save")
      expect(page).to have_content("You have successfully updated the autoresponder.")
    end

    it "lets a user set up an impact and consequences guide" do
      visit root_path
      click_on "My Projects"
      click_on(project.name)
      click_on("Impact and Consequences")
      expect(page).to have_content("Clone from")
      select "Beacon Default", from: "consequence_guide_default_source"
      click_on("Clone")
      expect(page).to have_content("Correction")
      fill_in "consequence_label", with: "Disciplinary Action"
      select "2", from: "consequence_severity"
      fill_in "consequence_action", with: "Personal attacks"
      fill_in "consequence_consequence", with: "Reprimand from moderators"
      click_on("Update Guide")
      expect(page).to have_content("Personal attacks")
    end

    it "lets a user modify project settings" do
      visit root_path
      click_on "My Projects"
      click_on(project.name)
      click_on("Project Settings")
      expect(page).to have_content("Settings")
      check("project_setting_include_in_directory")
      click_on("Update Settings")
    end

  end

  context "with an available organizations" do

    let!(:organization) { FactoryBot.create(:organization, account: maintainer) }
    let!(:org_project)  { FactoryBot.create(:project, account_id: maintainer.id, organization_id: organization.id) }

    before do
      Role.create(account_id: maintainer.id, organization_id: organization.id, is_owner: true)
      Role.create(account_id: maintainer.id, project_id: org_project.id, is_owner: true)
      guide = ConsequenceGuide.find_or_create_by(organization_id: organization.id)
      guide.consequences.create!(
        severity: 1,
        label: "Correction",
        action: "Use of inappropriate language, such as profanity, or other behavior deemed unprofessional or unwelcome in the community.",
        consequence: "A private, written warning from a moderator, with clarity of violation and explanation of why the behavior was inappropriate."
      )
      RespondentTemplate.create(
        organization_id: organization.id,
        text: "This is to inform you that you have been named as a respondent on a code of conduct issue."
      )
    end

    it "lets a user create a project" do
      visit root_path
      click_on "My Projects"
      click_on("New Project")
      expect(page).to have_content("Register a Project")
      fill_in "project_name", with: "CoC Beacon"
      fill_in "project_url", with: "https://github.com/contributorCovenant/beacon/"
      fill_in "project_coc_url", with: "https://github.com/contributorCovenant/beacon/CODE_OF_CONDUCT.md"
      fill_in "project_description", with: "A code of conduct reporting and management system."
      select organization.name, from: "project_organization_id"
      click_on "Create Project"
      expect(page).to have_content("CoC Beacon")
      expect(Project.find_by(name: "CoC Beacon").organization).to eq(organization)
    end

    it "lets a user clone an impact and consequences guide" do
      visit root_path
      click_on "My Projects"
      click_on(org_project.name)
      click_on("Impact and Consequences")
      expect(page).to have_content("Clone from")
      select "Organization Default", from: "consequence_guide_default_source"
      click_on("Clone")
      expect(page).to have_content("Correction")
      fill_in "consequence_label", with: "Disciplinary Action"
      select "2", from: "consequence_severity"
      fill_in "consequence_action", with: "Personal attacks"
      fill_in "consequence_consequence", with: "Reprimand from moderators"
      click_on("Update Guide")
      expect(page).to have_content("Personal attacks")
    end

    it "lets a user clone a respondent template" do
      visit root_path
      click_on "My Projects"
      click_on(org_project.name)
      click_on("Respondent Template")
      expect(page).to have_content("Clone from")
      select "Organization Default", from: "respondent_template_respondent_template_default_source"
      click_on("Clone")
      expect(page).to have_content("This is to inform you")
      fill_in "respondent_template_text", with: "We are sad to inform you"
      click_on("Save")
      expect(page).to have_content("You have successfully updated the respondent template.")
    end

    it "lets a user add an autoresponder" do
      visit root_path
      click_on "My Projects"
      click_on(org_project.name)
      click_on("Autoresponder")
      expect(page).to have_content("Clone from")
      select "Beacon Default", from: "autoresponder_default_source"
      click_on("Clone")
      expect(page).to have_content("Thank you for opening")
      click_on("Edit")
      fill_in "autoresponder_text", with: "Thanks so much"
      click_on("Save")
      expect(page).to have_content("You have successfully updated the autoresponder.")
    end

  end

end
