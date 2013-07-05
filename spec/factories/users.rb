require 'faker'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'secret'

    factory :admin do
      admin true
    end
  end
end