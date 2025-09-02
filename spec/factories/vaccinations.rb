FactoryBot.define do
  factory :vaccination do
    pet
    vaccine
    due_on { Faker::Date.forward(days: 30) }
    status { 'pending' }
  end
end
