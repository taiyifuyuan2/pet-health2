# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    pet
    notification_type { %w[vaccination medication health_advice].sample }
    title { Faker::Lorem.sentence(word_count: 3) }
    message { Faker::Lorem.paragraph }
    scheduled_for { Faker::Time.forward(days: 7) }
    status { 'pending' }
  end
end
