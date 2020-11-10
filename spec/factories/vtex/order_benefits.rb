FactoryBot.define do
  factory :vtex_order_benefit, class: 'Vtex::OrderBenefit' do
    order { nil }
    benefit { nil }
  end
end
