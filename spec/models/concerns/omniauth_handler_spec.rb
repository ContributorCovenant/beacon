require 'rails_helper'

RSpec.describe OmniauthHandler do

  let(:account_with_github){ FactoryBot.create(:bobby, :with_github_account_linked) }
  let(:account_with_gitlab){ FactoryBot.create(:ricky, :with_gitlab_account_linked) }
  let(:account_with_github_and_gitlab) do
    FactoryBot.create(:kate,
                      :with_github_account_linked,
                      :with_gitlab_account_linked)
  end
  let(:account){ FactoryBot.create(:danielle) }

  let(:github_auth) do
    OmniAuth::AuthHash.new(provider: 'github',
                           info: OmniAuth::AuthHash.new(email: 'example@github.com'),
                           uid: '123')
  end

  let(:gitlab_auth) do
    OmniAuth::AuthHash.new(provider: 'gitlab',
                           info: OmniAuth::AuthHash.new(email: 'example@gitlab.com'),
                           uid: '456')
  end

  let(:unconfigurd_auth) do
    OmniAuth::AuthHash.new(provider: 'unconf',
                           info: OmniAuth::AuthHash.new(email: 'example@unconf.com'),
                           uid: '789')
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
