FactoryBot.define do
  factory :walk_log do
    pet
    date { Faker::Date.between(from: 30.days.ago, to: Date.current) }
    distance_km { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
    duration_minutes { Faker::Number.between(from: 10, to: 120) }
    note { Faker::Lorem.sentence(word_count: 5) }
  end
end
