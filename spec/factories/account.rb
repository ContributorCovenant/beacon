FactoryBot.define do
  factory :account do
    confirmed_at { Time.zone.now }
    password { "1234567891011"}
  end
end
