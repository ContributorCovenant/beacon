require 'rails_helper'

RSpec.describe OmniauthHandler do

  let(:account_with_github){ FactoryBot.create(:account, :with_github_account_linked) }
  let(:account_with_gitlab){ FactoryBot.create(:account, :with_gitlab_account_linked) }
  let(:account_with_github_and_gitlab){ FactoryBot.create(:account,
                                                          :with_github_account_linked,
                                                          :with_gitlab_account_linked) }
  let(:account){ FactoryBot.create(:account) }

  let(:github_auth){
    OmniAuth::AuthHash.new(provider: 'github',
                           info: OmniAuth::AuthHash.new(email: 'example@github.com'),
                           uid: '123')
  }

  let(:gitlab_auth){
    OmniAuth::AuthHash.new(provider: 'gitlab',
                           info: OmniAuth::AuthHash.new(email: 'example@gitlab.com'),
                           uid: '456')
  }

  let(:unconfigurd_auth){
    OmniAuth::AuthHash.new(provider: 'unconf',
                           info: OmniAuth::AuthHash.new(email: 'example@unconf.com'),
                           uid: '789')
  }


  describe '.link_provider' do
    context 'linking a configured non linked providers' do
      context 'linking github & gitlab providers' do
        it 'should link the provider' do
          account.link_provider(github_auth)
          expect(account.credentials.count).to eq 1
          expect(account.credentials.first.email).to eq 'example@github.com'
          expect(account.credentials.first.uid).to eq '123'
          account.link_provider(gitlab_auth)
          expect(account.credentials.count).to eq 2
          gitlab_credential = account.credentials.where(provider: 'gitlab')
          expect(gitlab_credential.count).to eq 1
          expect(gitlab_credential.first.email).to eq 'example@gitlab.com'
          expect(gitlab_credential.first.uid).to eq '456'
        end
      end
    end

    context 'linking a non configured provider' do
      it 'should return false' do
        expect(account.link_provider(unconfigurd_auth)).to eq false
        expect(account.credentials.count).to eq 0
      end
    end

    context 'linking a linked provider' do
      it 'should return false' do
        account.link_provider(github_auth)
        expect(account.link_provider(github_auth)).to eq false
        expect(account.credentials.count).to eq 1
      end
    end
  end

  describe '.linked_to_provider?' do

    context 'when account is not linked to a provider' do
      it 'should return false' do
        expect(account.linked_to_github?).to eq false
        expect(account.linked_to_gitlab?).to eq false
        expect(account_with_github.linked_to_gitlab?).to eq false
        expect(account_with_gitlab.linked_to_github?).to eq false
      end
    end

    context 'when account is not linked to a particular provider' do
      it 'should return true' do
        expect(account_with_github.linked_to_github?).to eq true
        expect(account_with_gitlab.linked_to_gitlab?).to eq true
        expect(account_with_github_and_gitlab.linked_to_github?).to eq true
        expect(account_with_github_and_gitlab.linked_to_gitlab?).to eq true
      end
    end

  end

end
