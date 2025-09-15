FactoryBot.define do
  factory :invitation do
    household { nil }
    email { "MyString" }
    token { "MyString" }
    role { "MyString" }
    invited_by { nil }
    accepted_at { "2025-09-15 20:47:57" }
    expires_at { "2025-09-15 20:47:57" }
  end
end
