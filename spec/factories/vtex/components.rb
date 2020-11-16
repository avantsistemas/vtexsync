FactoryBot.define do
  factory :vtex_component, class: 'Vtex::Component' do
    order_item { nil }
    product { nil }
    identifier { "MyString" }
    quantity { 1 }
    price { "9.99" }
    selling_price { "9.99" }
  end
end
