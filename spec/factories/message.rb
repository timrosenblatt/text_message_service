FactoryGirl.define do
  factory :message do
    username { Faker::Internet.user_name }
    text { Faker::Company.catch_phrase }
    timeout { 10 + rand(20) }
  end
end