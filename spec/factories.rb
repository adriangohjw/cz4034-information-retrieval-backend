FactoryBot.define do

  factory :post do
    body { Faker::Hipster.paragraph }
    hashtags { nil }
    creator { Faker::Internet.username }
    verified { Faker::Boolean.boolean }
    followers { rand(10.1000) }
    following { rand(10..1000) }
    impressions { rand(0..10000) }
    upvotes { rand(0..100) }
    reposts { rand(0..100) }
    posted_at { nil }
  end

end