FactoryBot.define do
  factory :event do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    scheduled_at { Faker::Time.forward(days: 30) }
    event_type { 'vaccine' }
    status { 'pending' }
    household
    subject { association(:pet) }
  end
end
