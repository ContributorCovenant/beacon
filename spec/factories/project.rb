FactoryBot.define do
  sequence :project_name do |n|
    "Project #{n}"
  end
  sequence :project_slug do |n|
    "project-#{n}"
  end
end

FactoryBot.define do
  factory :project do
    id { SecureRandom.uuid }
    name { generate(:project_name) }
    url { "http://example.com/#{generate(:project_slug)}" }
    coc_url { "http://example.com/#{generate(:project_slug)}/conduct/" }
    description { "A sample project." }

    public { true }

    setup_complete { true }
  end
end
