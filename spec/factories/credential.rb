FactoryBot.define do
  factory :credential do

    uid { SecureRandom.uuid }
    provider{ Account.omniauth_providers.sample.to_s }
    email{ Faker::Internet.email }
    association :account, factory: :account

  end
end
