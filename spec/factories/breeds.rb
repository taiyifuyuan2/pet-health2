FactoryBot.define do
  factory :breed do
    name { Faker::Creature::Dog.breed }
    risk_tags do
      {
        "0-120" => ["一般的な健康リスク"],
        "60-120" => ["シニア期の注意点"]
      }
    end
  end
end
