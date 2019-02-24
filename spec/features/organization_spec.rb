require "rails_helper"

describe "organization management", type: :feature do

  let(:maintainer)    { FactoryBot.create(:danielle) }

  it "lets a user create an organization" do
    login_as(maintainer, scope: :account)
    visit root_path
    click_on("My Organizations")
    click_on("New Organization")
    expect(page).to have_content("Create an Organization")
    fill_in "Name", with: "Umbrella Corporation"
    fill_in "organization_url", with: "https://umbrellacorp.biz"
    fill_in "organization_coc_url", with: "https://umbrellacorp.biz/conduct.html"
    fill_in "organization_description", with: "A friendly corporation that is not up to no good."
    click_on "Create Organization"
    expect(page).to have_content("Umbrella Corporation")
  end

  context "existing organization" do

    let!(:organization) { FactoryBot.create(:organization, name: "Umbrella Corporation", account: maintainer) }

    before do
      Role.create(account_id: maintainer.id, organization_id: organization.id, is_owner: true)
      IssueSeverityLevel.create(
        scope: "template",
        severity: 1,
        label: "Correction",
        example: "Use of inappropriate language, such as profanity, or other behavior deemed unprofessional or unwelcome in the community.",
        consequence: "A private, written warning from project leadership, with clarity of violation and explanation of why the behavior was inappropriate."
      )
      RespondentTemplate.create(
        is_beacon_default: true,
        text: "This is to inform you that you have been named as a respondent on a code of conduct issue."
      )
    end

    it "lets a user add a consequence ladder" do
      login_as(maintainer, scope: :account)
      visit root_path
      click_on("My Organizations")
      click_on(organization.name)
      expect(page).to have_content("Setup Checklist")
      click_on("Consequence Ladder")
      expect(page).to have_content("Clone from")
      select "Beacon Default", :from => "organization_consequence_ladder_default_source"
      click_on("Clone")
      expect(page).to have_content("Correction")
      fill_in "issue_severity_level_label", with: "Disciplinary Action"
      select "2", from: "issue_severity_level_severity"
      fill_in "issue_severity_level_example", with: "Personal attacks"
      fill_in "issue_severity_level_consequence", with: "Reprimand from moderators"
      click_on("Update Ladder")
      expect(page).to have_content("Personal attacks")
    end

    it "lets a user add a respondent template" do
      login_as(maintainer, scope: :account)
      visit root_path
      click_on("My Organizations")
      click_on(organization.name)
      expect(page).to have_content("Setup Checklist")
      click_on("Respondent Template")
      expect(page).to have_content("Clone from")
      select "Beacon Default", from: "respondent_template_respondent_template_default_source"
      click_on("Clone")
      expect(page).to have_content("This is to inform you")
      fill_in "respondent_template_text", with: "We are sad to inform you"
      click_on("Save")
      expect(page).to have_content("You have successfully updated the respondent template.")
    end

    it "lets a user create a project" do
      login_as(maintainer, scope: :account)
      visit root_path
      click_on("My Organizations")
      click_on(organization.name)
      click_on("New Project")
      expect(page).to have_content("Register a Project")
      fill_in "project_name", with: "My Project 1"
      fill_in "project_url", with: "https://contributor-covenant.org"
      fill_in "project_coc_url", with: "https://contributor-covenant.org/conduct.html"
      fill_in "project_description", with: "The world's first code of conduct for open source projects."
      select "Umbrella Corporation", from: "project_organization_id"
      click_on("Create Project")
      expect(page).to have_content("Umbrella Corporation: My Project 1")
      expect(Project.last.organization_id).to eq(organization.id)
    end

  end

end
