require 'rails_helper'

RSpec.describe Accounts::OmniauthCallbacksController, type: :controller do
  before(:all) { OmniAuth.config.test_mode = true }

  let(:account){ FactoryBot.create(:account, email: 'ram@example.com') }

  describe '#provider' do
    let(:callback){ get :github }

    before do
      OmniAuth.config.add_mock(
        :github,
        info: {
          email: "sam@example.com"
        },
        uid: '1234',
        provider: 'github'
      )
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
      request.env["devise.mapping"] = Devise.mappings[:account]
    end

    context 'new account' do
      it 'register account and create a credential for it' do
        expect { callback }.to change { Account.count }.by(1)
          .and change { Credential.count }.by(1)
      end

      it 'sign in the account' do
        callback
        expect(controller.current_account).to eq Account.last
      end

    end

    context 'linking a logged in account' do
      it 'should add a credential' do
        expect(account.credentials.count).to eq 0
        sign_in account
        expect { callback }.to change { Account.count }.by(0)
          .and change { Credential.count }.by(1)
        expect(account.credentials.count).to eq 1
        expect(account.email).to eq 'ram@example.com'
        expect(account.credentials.first.email).to eq 'sam@example.com'
      end
    end
  end
end
