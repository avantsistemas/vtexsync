FactoryBot.define do
  factory :vtex_sla, class: 'Vtex::Sla' do
    identifier { "MyString" }
    name { "MyString" }
    shipping_estimate { "MyString" }
    transit_time { "MyString" }
    price { "MyString" }
  end
end
