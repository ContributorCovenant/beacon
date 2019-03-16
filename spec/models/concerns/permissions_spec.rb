require 'rails_helper'

RSpec.describe Permissions do

  let(:kate)    { FactoryBot.create(:kate) }
  let(:exene)   { FactoryBot.create(:exene) }
  let(:peter)   { FactoryBot.create(:peter) }
  let(:ricky)   { FactoryBot.create(:ricky) }
  let(:donnie)  { FactoryBot.create(:donnie) }
  let(:public_project)  { FactoryBot.create(:project, account: kate) }
  let(:paused_project)  { FactoryBot.create(:project, account: kate) }
  let(:private_project) { FactoryBot.create(:project, account: kate) }

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    allow(public_project).to receive(:public?).and_return(true)
    allow(private_project).to receive(:public?).and_return(false)
    allow(paused_project).to receive(:paused?).and_return(true)
    Role.create(account_id: kate.id, project_id: public_project.id, is_owner: true)
    Role.create(account_id: kate.id, project_id: paused_project.id, is_owner: true)
    Role.create(account_id: kate.id, project_id: private_project.id, is_owner: true)
  end

  describe "#can_create_project?" do

    it "allows anyone" do
      expect(kate.can_create_project?).to be_truthy
      expect(exene.can_create_project?).to be_truthy
      expect(donnie.can_create_project?).to be_truthy
    end

  end

  describe "#can_open_issue_on_project?" do

    context "public project" do
      it "allows anyone" do
        expect(exene.can_open_issue_on_project?(public_project)).to be_truthy
        expect(donnie.can_open_issue_on_project?(public_project)).to be_truthy
      end
    end

    context "private project" do
      it "allows no one" do
        expect(exene.can_open_issue_on_project?(private_project)).to be_falsey
        expect(donnie.can_open_issue_on_project?(private_project)).to be_falsey
        expect(kate.can_open_issue_on_project?(private_project)).to be_falsey
      end
    end

    context "paused project" do
      it "allows no one" do
        expect(exene.can_open_issue_on_project?(paused_project)).to be_falsey
        expect(donnie.can_open_issue_on_project?(paused_project)).to be_falsey
        expect(kate.can_open_issue_on_project?(paused_project)).to be_falsey
      end
    end

    context "project requiring 3rd party auth" do

      before do
        allow(exene).to receive(:has_3rd_party_credentials?).and_return(true)
        allow(donnie).to receive(:has_3rd_party_credentials?).and_return(false)
        allow_any_instance_of(ProjectSetting).to receive(:require_3rd_party_auth).and_return(true)
      end

      it "allows an account with 3rd party credentials" do
        expect(exene.can_open_issue_on_project?(public_project)).to be_truthy
      end

      it "denies an account without 3rd party credentials" do
        expect(donnie.can_open_issue_on_project?(public_project)).to be_falsey
      end

    end

  end

  describe "#can_comment_on_issue?" do

    let(:issue) { FactoryBot.create(:issue, project_id: public_project.id, reporter_id: exene.id) }

    before do
      allow(issue).to receive(:respondent).and_return(ricky)
    end

    it "allows a project moderator" do
      expect(kate.can_comment_on_issue?(issue)).to be_truthy
    end

    it "allows a reporter" do
      expect(exene.can_comment_on_issue?(issue)).to be_truthy
    end

    it "allows a respondent" do
      expect(ricky.can_comment_on_issue?(issue)).to be_truthy
    end

    it "does not allow a rando" do
      expect(donnie.can_comment_on_issue?(issue)).to be_falsey
    end

  end

  describe "#can_view_issue?" do

    let(:issue) { FactoryBot.create(:issue, project_id: public_project.id, reporter_id: exene.id) }

    before do
      allow(issue).to receive(:respondent).and_return(ricky)
    end

    it "allows a project moderator" do
      expect(kate.can_view_issue?(issue)).to be_truthy
    end

    it "allows a reporter" do
      expect(exene.can_view_issue?(issue)).to be_truthy
    end

    it "allows a respondent" do
      expect(ricky.can_view_issue?(issue)).to be_truthy
    end

    it "does not allow a rando" do
      expect(donnie.can_view_issue?(issue)).to be_falsey
    end

  end

  describe "#can_invite_respondent?" do

    let(:issue) { FactoryBot.create(:issue, project_id: public_project.id, reporter_id: exene.id) }

    before do
      allow(issue).to receive(:respondent).and_return(ricky)
    end

    it "allows a moderator" do
      expect(kate.can_invite_respondent?(issue)).to be_truthy
    end

    it "does not allow a reporter" do
      expect(exene.can_invite_respondent?(issue)).to be_falsey
    end

    it "does not allow a rando" do
      expect(donnie.can_invite_respondent?(issue)).to be_falsey
    end

  end

  describe "#can_moderate_project?" do

    it "allows a moderator" do
      expect(kate.can_moderate_project?(public_project)).to be_truthy
    end

    it "does not allow a rando" do
      expect(donnie.can_moderate_project?(public_project)).to be_falsey
    end

  end

  describe "#can_manage_project?" do

    it "allows a projec owner" do
      expect(kate.can_manage_project?(public_project)).to be_truthy
    end

    it "does not allow a moderator" do
      expect(peter.can_moderate_project?(public_project)).to be_falsey
    end

    it "does not allow a rando" do
      expect(donnie.can_moderate_project?(public_project)).to be_falsey
    end

  end

end
