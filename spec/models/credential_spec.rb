require 'rails_helper'

RSpec.describe Credential, type: :model  do

  let(:credential){ FactoryBot.build(:credential) }

  describe 'valid?' do

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

    context 'credential has a in the Account model configured provider' do
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

end
