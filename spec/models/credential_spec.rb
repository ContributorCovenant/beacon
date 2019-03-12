require 'rails_helper'

RSpec.describe Credential, type: :model  do

  let(:credential){ FactoryBot.build(:credential) }

  let(:auth_data) do
    OmniAuth::AuthHash.new(provider: credential.provider,
                           info: OmniAuth::AuthHash.new(email: credential.email),
                           uid: credential.uid)
  end

  describe '.valid?' do
    context 'corresponding account' do
      context 'it has a corresponding account' do
        it 'should be valid' do
          expect(credential.valid?).to eq true
        end
      end

      context 'it does not have an associated account' do
        it 'should not be valid' do
          credential.account = nil
          expect(credential.valid?).to eq false
        end
      end
    end

    context 'credential provider is configured in the account model' do
      it 'should be valid' do
        expect(credential.valid?).to eq true
      end
    end

    context 'credential has a provider that is not configured in the account model' do
      it 'credential is not valid' do
        credential.provider = 'non existent third party provider'
        expect(credential.valid?).to eq false
      end
    end
  end

  describe '#find_with_omniauth' do
    it 'should return the credential' do
      credential.save!
      expect(Credential.find_with_omniauth(auth_data)).to eq credential
    end
  end
end
