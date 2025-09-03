# frozen_string_literal: true

FactoryBot.define do
  factory :household do
    name { Faker::Company.name }
  end
end
