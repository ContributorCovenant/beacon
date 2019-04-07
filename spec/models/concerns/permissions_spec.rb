require 'rails_helper'

RSpec.describe Permissions do

  let(:kate)    { FactoryBot.create(:kate) }
  let(:exene)   { FactoryBot.create(:exene) }
  let(:peter)   { FactoryBot.create(:peter) }
  let(:ricky)   { FactoryBot.create(:ricky) }
  let(:donnie)  { FactoryBot.create(:donnie) }
  let(:admin)   { FactoryBot.create(:admin) }
  let(:public_project)  { FactoryBot.create(:project, account: kate) }
  let(:paused_project)  { FactoryBot.create(:project, account: kate) }
  let(:private_project) { FactoryBot.create(:project, account: kate) }
  let(:issue) { FactoryBot.create(:issue, project_id: public_project.id) }
  let(:organization) { Organization.create(name: "Umbrella Corporation", account: kate) }

  before do
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    allow(public_project).to receive(:public?).and_return(true)
    allow(private_project).to receive(:public?).and_return(false)
    allow(paused_project).to receive(:paused?).and_return(true)
    Role.create(account_id: kate.id, project_id: public_project.id, is_owner: true)
    Role.create(account_id: peter.id, project_id: public_project.id)
    Role.create(account_id: kate.id, project_id: paused_project.id, is_owner: true)
    Role.create(account_id: kate.id, project_id: private_project.id, is_owner: true)
    Role.create(account_id: kate.id, organization_id: organization.id, is_owner: true)
    Role.create(account_id: exene.id, organization_id: organization.id, is_default_moderator: true)
  end

  describe "#can_create_project?" do

    it "allows anyone" do
      expect(kate.can_create_project?).to be_truthy
      expect(exene.can_create_project?).to be_truthy
      expect(donnie.can_create_project?).to be_truthy
    end

  end

  context "admin dashboards" do

    describe "#can_access_abuse_reports?" do
      it "allows an admin" do
        expect(admin.can_access_abuse_reports?).to be_truthy
      end
      it "disallows non-admins" do
        expect(exene.can_access_abuse_reports?).to be_falsey
      end
    end

    describe "#can_access_admin_dashboard?" do
      it "allows an admin" do
        expect(admin.can_access_admin_dashboard?).to be_truthy
      end
      it "disallows non-admins" do
        expect(exene.can_access_admin_dashboard?).to be_falsey
      end
    end

    describe "#can_access_admin_organization_dashboard?" do
      it "allows an admin" do
        expect(admin.can_access_admin_organization_dashboard?).to be_truthy
      end
      it "disallows non-admins" do
        expect(exene.can_access_admin_organization_dashboard?).to be_falsey
      end
    end

    describe "#can_access_admin_project_dashboard?" do
      it "allows an admin" do
        expect(admin.can_access_admin_project_dashboard?).to be_truthy
      end
      it "disallows non-admins" do
        expect(exene.can_access_admin_project_dashboard?).to be_falsey
      end
    end

    describe "#can_lock_account?" do
      it "allows an admin" do
        expect(admin.can_lock_account?).to be_truthy
      end
      it "disallows non-admins" do
        expect(exene.can_lock_account?).to be_falsey
      end
    end

    describe "#can_lock_project?" do
      it "allows an admin" do
        expect(admin.can_lock_project?).to be_truthy
      end
      it "disallows non-admins" do
        expect(exene.can_lock_project?).to be_falsey
      end
    end

  end

  describe "#can_block_account?" do
    it "allows a project moderator" do
      expect(kate.can_block_account?(public_project)).to be_truthy
    end
    it "does not allow a rando" do
      expect(donnie.can_block_account?(public_project)).to be_falsey
    end
  end

  describe "#can_view_survey_on_issue?" do
    it "allows a project moderator" do
      expect(kate.can_view_survey_on_issue?(public_project)).to be_truthy
    end
    it "does not allow a rando" do
      expect(donnie.can_view_survey_on_issue?(public_project)).to be_falsey
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
        allow(exene).to receive(:third_party_credentials?).and_return(true)
        allow(donnie).to receive(:third_party_credentials?).and_return(false)
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

  describe "#can_manage_project_autoresponder?" do
    it "allows a project moderator" do
      expect(kate.can_manage_project_autoresponder?(public_project)).to be_truthy
    end
    it "does not allow a rando" do
      expect(donnie.can_manage_project_autoresponder?(public_project)).to be_falsey
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

  describe "#can_upload_images_to_issue?" do

    let(:issue) { FactoryBot.create(:issue, project_id: public_project.id, reporter_id: exene.id) }

    before do
      allow(issue).to receive(:reporter).and_return(peter)
    end
    it "allows a reporter" do
      expect(peter.can_upload_images_to_issue?(issue)).to be_truthy
    end
    it "does not allow a rando" do
      expect(donnie.can_upload_images_to_issue?(issue)).to be_falsey
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

  describe "#can_complete_survey_on_issue?" do

    let(:survey) { Survey.new }

    before do
      allow_any_instance_of(Issue).to receive(:reporter).and_return(exene)
      allow_any_instance_of(Issue).to receive(:respondent).and_return(donnie)
    end

    context "reporters and respondents who have not submitted a survey" do

      it "allows a reporter" do
        expect(exene.can_complete_survey_on_issue?(issue, public_project)).to be_truthy
      end

      it "allows a respondent" do
        expect(donnie.can_complete_survey_on_issue?(issue, public_project)).to be_truthy
      end

    end

    context "reporters who have already submitted a survey" do
      before do
        allow_any_instance_of(Survey).to receive(:account).and_return(exene)
        allow_any_instance_of(Survey).to receive(:issue).and_return(issue)
        allow_any_instance_of(Project).to receive(:surveys).and_return([survey])
      end
      it "does not allow" do
        expect(exene.can_complete_survey_on_issue?(issue, public_project)).to be_falsey
      end
    end

    context "respondents who have already submitted a survey" do
      before do
        allow_any_instance_of(Survey).to receive(:account).and_return(donnie)
        allow_any_instance_of(Survey).to receive(:issue).and_return(issue)
        allow_any_instance_of(Project).to receive(:surveys).and_return([survey])
      end
      it "does not allow" do
        expect(donnie.can_complete_survey_on_issue?(issue, public_project)).to be_falsey
      end
    end

    it "does not permit randos" do
      expect(ricky.can_complete_survey_on_issue?(issue, public_project)).to be_falsey
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

    it "allows a project owner" do
      expect(kate.can_manage_project?(public_project)).to be_truthy
    end

    it "does not allow a moderator" do
      expect(peter.can_manage_project?(public_project)).to be_falsey
    end

    it "does not allow a rando" do
      expect(donnie.can_moderate_project?(public_project)).to be_falsey
    end

  end

  describe "#can_manage_project_consequence_guide?" do

    it "allows a project owner" do
      expect(kate.can_manage_project_consequence_guide?(public_project)).to be_truthy
    end

    it "allows a moderator" do
      expect(peter.can_manage_project_consequence_guide?(public_project)).to be_truthy
    end

    it "does not allow a rando" do
      expect(donnie.can_manage_project_consequence_guide?(public_project)).to be_falsey
    end

  end

  context "organizations" do

    describe "#can_manage_organization_autoresponder?" do
      it "allows an owner" do
        expect(kate.can_manage_organization_autoresponder?(organization)).to be_truthy
      end
      it "does not allow a moderator" do
        expect(exene.can_manage_organization_autoresponder?(organization)).to be_falsey
      end
    end

    describe "#can_manage_organization_consequence_guide?" do
      it "allows an owner" do
        expect(kate.can_manage_organization_consequence_guide?(organization)).to be_truthy
      end
      it "does not allow a moderator" do
        expect(exene.can_manage_organization_consequence_guide?(organization)).to be_falsey
      end
    end

    describe "#can_manage_organization_respondent_template?" do
      it "allows an owner" do
        expect(kate.can_manage_organization_respondent_template?(organization)).to be_truthy
      end
      it "does not allow a moderator" do
        expect(exene.can_manage_organization_respondent_template?(organization)).to be_falsey
      end
    end

  end

end
