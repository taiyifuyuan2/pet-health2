FactoryBot.define do
  factory :membership do
    user
    household
    role { 'owner' }
  end
end
