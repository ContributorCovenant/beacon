require 'rails_helper'

RSpec.describe NotificationService do

  let(:account) { FactoryBot.create(:peter) }
  let(:project) { FactoryBot.create(:project, account: account) }
  let(:issue_1)   { FactoryBot.create(:issue, project_id: project.id) }
  let(:issue_2)   { FactoryBot.create(:issue, project_id: project.id) }
  let(:issue_3)   { FactoryBot.create(:issue, project_id: project.id) }

  describe "#notify" do

    it "creates a notification" do
      NotificationService.notify(account: account, project_id: project.id, issue_id: issue_1.id)
      expect(account.notifications.size).to eq(1)
    end

  end

  describe "#notified!" do

    it "destroys a notification" do
      NotificationService.notify(account: account, project_id: project.id, issue_id: issue_1.id)
      NotificationService.notify(account: account, project_id: project.id, issue_id: issue_2.id)
      NotificationService.notify(account: account, project_id: project.id, issue_id: issue_3.id)
      NotificationService.notified!(account: account, issue_id: issue_1.id)
      account_reloaded = Account.find_by(email: account.email)
      expect(account_reloaded.notifications.size).to eq(2)
    end

  end

end
