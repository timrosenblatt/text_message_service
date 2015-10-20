FactoryGirl.define do
  factory :message do
    username { Faker::Internet.user_name }
    text { Faker::Company.catch_phrase }
    timeout { rand(120) }
  end
end