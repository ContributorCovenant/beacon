FactoryBot.define do
  factory :project do
    id { SecureRandom.uuid }
    slug { "sample-project" }
    name { "Sample Project" }
    url { "http://example.com/sample" }
    coc_url { "http://example.com/sample/conduct/" }
    description { "A sample project." }
  end
end
