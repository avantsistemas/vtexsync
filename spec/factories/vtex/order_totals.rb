FactoryBot.define do
  factory :vtex_order_total, class: 'Vtex::OrderTotal' do
    order { nil }
    total { nil }
    value { "9.99" }
  end
end
