FactoryBot.define do
  factory :vaccine do
    name { Faker::Lorem.words(number: 2).join(' ') + 'ワクチン' }
    description { Faker::Lorem.paragraph }
  end
end
