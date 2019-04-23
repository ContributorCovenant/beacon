require 'rails_helper'

RSpec.describe Project, type: :model  do

  let(:maintainer) { FactoryBot.build(:kate) }
  let(:project){ FactoryBot.create(:project, account: maintainer, name: "We 🖤 Ruby") }

  it "sanitizes the project slug" do
    expect(project.slug).to eq("we_ruby")
  end

end
