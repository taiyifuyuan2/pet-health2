FactoryBot.define do
  factory :weight_record do
    pet
    date { Faker::Date.between(from: 30.days.ago, to: Date.current) }
    weight_kg { Faker::Number.decimal(l_digits: 2, r_digits: 1) }
    note { Faker::Lorem.sentence(word_count: 5) }
  end
end
