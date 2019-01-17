FactoryBot.define do
  factory :account do
    confirmed_at { Time.zone.now }
  end
end
