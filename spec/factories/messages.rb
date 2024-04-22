FactoryBot.define do
  factory :message do
    user
    association :visit, factory: :staff_visit
    body { 'a staff message to the user' }
  end
end
