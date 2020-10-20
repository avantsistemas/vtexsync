FactoryBot.define do
  factory :vtex_order_item, class: 'Vtex::OrderItem' do
    order { nil }
    product { nil }
    vtex_code { "MyString" }
    quantity { 1 }
    price { "9.99" }
  end
end
