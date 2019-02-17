require "rails_helper"

describe "the reporting process", type: :feature do

  let(:maintainer) { FactoryBot.create(:danielle) }
  let!(:project) { FactoryBot.create(:project, account: maintainer, public: true) }
  let(:reporter) { FactoryBot.create(:michael) }

  before do
    allow_any_instance_of(Project).to receive(:show_in_directory?).and_return(true)
    allow_any_instance_of(Accounts::RegistrationsController).to receive(:verify_recaptcha).and_return(true)
    allow_any_instance_of(IssuesController).to receive(:verify_recaptcha).and_return(true)
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
    visit directory_path
    expect(page).to have_content(project.name)
    click_on(project.name)
    click_on("Open an Issue")
    expect(page).to have_content("Open an Issue in #{project.name}")
    fill_in "issue_description", with: "So this is what happened."
    click_on "Open Issue"
    expect(page).to have_content("Discussion with Moderators")
    fill_in "issue_comment_text", with: "Thanks for looking into this!"
    click_on "Send Message"
    expect(page).to have_content("Thanks")
  end

end
