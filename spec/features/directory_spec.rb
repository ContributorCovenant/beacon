require "rails_helper"

describe "the directory", type: :feature do

  let(:maintainer) { FactoryBot.create(:danielle) }
  let!(:project_1) { FactoryBot.create(:project, name: "Beacon Project", account: maintainer, public: true) }
  let!(:project_2) { FactoryBot.create(:project, name: "Contributor Covenant", account: maintainer, public: true) }
  let!(:project_3) { FactoryBot.create(:project, name: "Zellophane", organization_name: "ZebraCom", account: maintainer, public: true) }

  before do
    allow_any_instance_of(Project).to receive(:show_in_directory?).and_return(true)
  end

  it "enables browsing by first letter" do
    visit directory_path
    expect(page).to have_content "Beacon Project"
    within all(".pagination li") { click_on "C" }
    expect(page).to have_content "Contributor Covenant"
  end

  it "allows search by project name" do
    visit directory_path
    fill_in "q", with: "contr"
    click_on "Search"
    expect(page).to have_content("Contributor Covenant")
  end

  it "displays a project page" do
    visit directory_path
    click_on "Beacon Project"
    expect(page).to have_content("View code of conduct")
  end

end
