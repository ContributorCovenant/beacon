require "rails_helper"

describe "the reporting process", type: :feature do

  let(:maintainer) { FactoryBot.create(:danielle) }
  let!(:project) { FactoryBot.create(:project, account: maintainer, public: true) }
  let!(:another_project) { FactoryBot.create(:project, name: "Theory X", account: maintainer, public: true) }
  let(:reporter) { FactoryBot.create(:ricky) }

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    allow_any_instance_of(Project).to receive(:publicly_accessible?).and_return(true)
    allow_any_instance_of(Accounts::RegistrationsController).to receive(:verify_recaptcha).and_return(true)
    allow_any_instance_of(IssuesController).to receive(:verify_recaptcha).and_return(true)
    Role.create(account_id: maintainer.id, project_id: project.id, is_owner: true)
    Autoresponder.create(project: project, text: "Foo")
  end

  it "lets a reporter register" do
    visit new_account_registration_path
    fill_in "Email", with: "jones@idolhands.com"
    fill_in "Password", with: "123456789abc"
    fill_in "Password confirmation", with: "123456789abc"
    click_button "Sign Up"
    expect(page).to have_content "message with a confirmation link"
  end

  it "enables a reporter to sign in" do
    visit new_account_session_path
    fill_in "Email", with: reporter.email
    fill_in "Password", with: reporter.password
    click_button "Sign In"
    expect(page).to have_content "Signed in successfully."
  end

  it "lets a reporter open an issue" do
    login_as(reporter, scope: :account)
    visit directory_project_path(project)
    click_on("Open an Issue")
    expect(page).to have_content("Open an Issue in #{project.name}")
    fill_in "issue_description", with: "So this is what happened."
    click_on "Open Issue"
    expect(page).to have_content("Discussion with Moderators")
    fill_in "issue_comment_text", with: "Thanks for looking into this!"
    click_on "Send Message"
    expect(page).to have_content("Thanks")
  end

  it "lets a reporter report a project for abuse" do
    login_as(reporter, scope: :account)
    visit directory_project_path(project)
    click_on("Report This Project")
    expect(page).to have_content("Report Abuse: #{project.name}")
    fill_in "Explanation", with: "This project's name is offensive."
    click_on "Report Project"
    expect(page).to have_content("Your report has been sent")
    expect(page).to have_content(project.name)
  end

  it "lets a reporter search for a project" do
    login_as(reporter, scope: :account)
    visit root_path
    fill_in 'q', with: "T"
    click_on "Search"
    expect(page).to have_content(another_project.name)
  end

end
