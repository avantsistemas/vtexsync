FactoryBot.define do
  factory :vtex_address, class: 'Vtex::Address' do
    city { nil }
    vtex_code { "MyString" }
    address_type { "MyString" }
    receiver_name { "MyString" }
    postal_code { "MyString" }
    street { "MyString" }
    number { "MyString" }
    neighborhood { "MyString" }
    complement { "MyString" }
    reference { "MyString" }
    latitude { 1 }
    longitude { 1 }
  end
end
