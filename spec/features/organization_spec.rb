require "rails_helper"

describe "organization management", type: :feature do

  let(:maintainer) { FactoryBot.create(:danielle) }

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
  end

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

    it "lets a user add an impact and consequences guide" do
      login_as(maintainer, scope: :account)
      visit root_path
      click_on("My Organizations")
      click_on(organization.name)
      expect(page).to have_content("Setup Checklist")
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
      allow_any_instance_of(Organization).to receive(:setup_complete?).and_return(true)
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
