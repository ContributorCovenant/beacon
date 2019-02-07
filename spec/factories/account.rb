FactoryBot.define do
  factory :account do
    confirmed_at { Time.zone.now }
    password { "1234567891011" }
    email { Faker::Internet.email }

    trait :with_github_account_linked do
      after(:create) do |account, evaluator|
        FactoryBot.create(:credential, account: account, provider: 'github')
      end
    end

    trait :with_gitlab_account_linked do
      after(:create) do |account, evaluator|
        FactoryBot.create(:credential, account: account, provider: 'gitlab' )
      end
    end
    
    # Danielle is a project maintainer for a small, one-person open source project.
    factory :danielle do
      email { "danielle@dax.com" }
    end

    # Kate is a project owner for a medium-sized open source project with several moderators.
    factory :kate do
      email { "kate@bush.com" }
    end

    # Peter is a moderator on a large enterprise open source project.
    factory :peter do
      email { "peter@murphy.com" }
    end

    # Exene is an open source developer who keeps her nose pretty clean, all things considered.
    factory :exene do
      email { "exene@cervenka.com" }
    end

    # Ricky is an open source developer who occasionally puts his foot in his mouth.
    factory :ricky do
      email { "ricky@martin.com" }
    end

    # Bobby is an open source developer who is known for his temper.
    factory :bobby do
      email { "bobby@brown.com" }
    end

    # Donnie is a script kiddie who hates codes of conduct.
    factory :donnie do
      email { "donnie@wahlberg.com" }
    end

    # Michael thinks that Coraline is the devil and hates all 'Social Justice Warriors'
    factory :michael do
      email { "michael@mccary.com" }
    end

  end
end
