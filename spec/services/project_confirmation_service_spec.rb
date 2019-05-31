require 'rails_helper'

RSpec.describe ProjectConfirmationService do

  let(:project) { FactoryBot.build(:project, confirmation_token_url: "https://google.com/beacon.txt") }
  let(:service) { ProjectConfirmationService.new(project, nil, nil) }

  context "#confirm_via_token" do

    let(:valid_token) { project.confirmation_token }
    let(:invalid_token) { "123456" }

    it "confirms if token is present" do
      expect_any_instance_of(URI::HTTPS).to receive(:read).and_return(valid_token)
      expect(service.confirm!).to be_truthy
    end

    it "doesn't confirm if token is wrong" do
      expect_any_instance_of(URI::HTTPS).to receive(:read).and_return(invalid_token)
      expect(service.confirm!).to be_falsey
    end

    it "doesn't confirm if URL is invalid" do
      project.confirmation_token_url = "lolno"
      expect(service.confirm!).to be_falsey
    end

  end

  context "#confirm_via_oauth" do

    let(:gitlab_credential) { Credential.new(uid: "123", provider: "gitlab") }
    let(:github_credential) { Credential.new(uid: "456", provider: "github") }

    context "with gitlab credentials" do

      let(:service) { ProjectConfirmationService.new(project, gitlab_credential, "gitlab") }
      let(:client) { double("GitLab client") }

      context "success" do
        before do
          allow(service).to receive(:gitlab_client).and_return(client)
          allow(client).to receive(:project).and_return(Hashie::Mash.new(owner: { id: gitlab_credential.uid }))
        end
        it "confirms if the project matches the credential" do
          expect(service.confirm!).to be_truthy
        end
      end

      context "failure" do
        before do
          allow(service).to receive(:gitlab_client).and_return(client)
          allow(client).to receive(:project).and_return(Hashie::Mash.new(owner: { id: 456 }))
        end
        it "rejects if the project matches the credential" do
          expect(service.confirm!).to be_falsey
        end
      end

    end

    context "with github credentials" do

      let(:service) { ProjectConfirmationService.new(project, github_credential, "github") }
      let(:client) { double("GitHub client") }

      context "success" do
        before do
          allow(service).to receive(:github_client).and_return(client)
          allow(client)
            .to receive(:search_repositories)
            .and_return(
              Hashie::Mash.new(
                items: [owner: { id: github_credential.uid }, fork: false]
              )
            )
        end
        it "confirms if the project matches the credential" do
          expect(service.confirm!).to be_truthy
        end
      end

      context "failure" do
        before do
          allow(service).to receive(:github_client).and_return(client)
          allow(client)
            .to receive(:search_repositories)
            .and_return(
              Hashie::Mash.new(
                items: [owner: { id: 789 }, fork: false]
              )
            )
        end
        it "rejects if the project matches the credential" do
          expect(service.confirm!).to be_falsey
        end
      end

    end

  end
end
