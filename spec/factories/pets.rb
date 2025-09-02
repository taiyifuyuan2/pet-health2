FactoryBot.define do
  factory :pet do
    name { Faker::Creature::Dog.name }
    species { 'dog' }
    sex { %w[male female unknown].sample }
    birthdate { Faker::Date.birthday(min_age: 0, max_age: 15) }
    weight_kg { Faker::Number.decimal(l_digits: 1, r_digits: 1) }
    notes { Faker::Lorem.sentence }
    household
    breed
  end
end
