FactoryBot.define do
  factory :vtex_logistic, class: 'Vtex::Logistic' do
    order_item { nil }
    selected_sla { "MyString" }
    delivery_company { "MyString" }
    shipping_estimate { "MyString" }
    shipping_estimate_date { "2021-03-02 17:19:15" }
  end
end
