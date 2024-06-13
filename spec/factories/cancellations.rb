FactoryBot.define do
  factory :cancellation, class: 'Staff::Cancellation' do
    association :visit, processing_state: 'cancelled', factory: :staff_visit
    reasons { ['prisoner_moved'] }
  end
end
