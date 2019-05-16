require "rails_helper"

RSpec.describe Accounts::SessionsController, type: :controller do
  describe '#create' do
    let(:moderator) { FactoryBot.create(:danielle) }
    let(:reporter)  { FactoryBot.build(:exene) }
    let!(:project)  { FactoryBot.create(:project, account: moderator) }

    before do
      Role.create(account_id: moderator.id, project_id: project.id, is_owner: true)

      # We are explicitly setting the Devise mapping in order to
      # bypass the router. That's because we are explicitly testing login,
      # not logging in to test other stuff. This is not good practice for
      # most tests in most cases.
      @request.env["devise.mapping"] = Devise.mappings[:account]
    end

    context "attempted non-Tor login while not checking login via proxies or Tor exit nodes" do
      before do
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_PROXY").and_return(nil)
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_TOR").and_return(nil)
      end

      it "permits login with no disallowed headers" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "1234567891011",
        }
        expect(controller.current_account).to be_truthy
      end

      # We're overriding SessionsController#create, so it's important to
      # test this.
      it "does not allow login with an incorrect password" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "7",
        }
        expect(controller.current_account).to be_falsy
      end

      # We're overriding SessionsController#create, so it's important to
      # test this.
      it "does not allow login with no password" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
        }
        expect(controller.current_account).to be_falsy
      end

      it "allows login with an X-FORWARDED-FOR header" do
        # RSpec isn't passing headers in the POST: https://github.com/rspec/rspec-rails/issues/1655
        request.headers.merge!({ "X-FORWARDED-FOR" => "some.domain.com" })
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "1234567891011",
        }
        expect(controller.current_account).to be_truthy
      end
    end

    context "attempted non-Tor login while disallowing login via proxies and Tor exit nodes" do
      before do
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_PROXY").and_return("true")
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_TOR").and_return("true")
        allow(Tor::DNSEL).to receive(:include?).and_return(false) # Not a Tor exit node
      end

      it "permits login with no disallowed headers" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "1234567891011",
        }
        expect(controller.current_account).to be_truthy
      end

      # We're overriding SessionsController#create, so it's important to
      # test this.
      it "does not allow login with an incorrect password" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "7",
        }
        expect(controller.current_account).to be_falsy
      end

      # We're overriding SessionsController#create, so it's important to
      # test this.
      it "does not allow login with no password" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
        }
        expect(controller.current_account).to be_falsy
      end
    end

    context "attempted login via proxy, while disallowing proxy and Tor login" do
      before do
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_PROXY").and_return("true")
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_TOR").and_return("true")
        allow(Tor::DNSEL).to receive(:include?).and_return(false) # Not a Tor exit node
      end

      it "does not allow login with an X-FORWARDED-FOR header" do
        # RSpec isn't passing headers in the POST: https://github.com/rspec/rspec-rails/issues/1655
        request.headers.merge!({ "X-FORWARDED-FOR" => "some.domain.com" })
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "1234567891011",
        }
        expect(controller.current_account).to be_falsy
      end
    end

    context "attempted login via Tor exit node while that's forbidden" do
      before do
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_PROXY").and_return("true")
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_TOR").and_return("true")
        allow(Tor::DNSEL).to receive(:include?).and_return(true)
      end

      it "does not allow login via Tor exit node" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "1234567891011",
        }
        expect(controller.current_account).to be_falsy
      end

      it "does not allow login via Tor exit node with Proxy headers" do
        request.headers.merge!({ "X-FORWARDED-FOR" => "some.domain.com" })
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "1234567891011",
        }
        expect(controller.current_account).to be_falsy
      end
    end

    context "attempted login via any node when Tor DNSEL is down" do
      before do
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_PROXY").and_return("true")
        allow(ENV).to receive(:[]).with("BLOCK_LOGIN_VIA_TOR").and_return("true")
        allow(Tor::DNSEL).to receive(:include?).and_return(nil)  # This happens on timeout/error in Tor DNSEL
      end

      it "allows login when Tor status is unknown" do
        post :create, params: {
            "account[email]" => "danielle@dax.com",
            "account[password]" => "1234567891011",
        }
        expect(controller.current_account).to be_truthy
      end

    end
  end
end
