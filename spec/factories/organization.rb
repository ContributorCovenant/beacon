FactoryBot.define do
  sequence :org_name do |n|
    "Organization #{n}"
  end
  sequence :org_slug do |n|
    "organization_#{n}"
  end
end

FactoryBot.define do
  factory :organization do
    id { SecureRandom.uuid }
    name { generate(:project_name) }
    url { "http://example.com/#{generate(:project_slug)}" }
    coc_url { "http://example.com/#{generate(:project_slug)}/conduct/" }
    description { "A sample organization." }
  end
end
