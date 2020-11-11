FactoryBot.define do
  factory :vtex_campaign, class: 'Vtex::Campaign' do
    order { nil }
    utm_source { "MyString" }
    utm_partner { "MyString" }
    utm_medium { "MyString" }
    utm_campaign { "MyString" }
    coupon { "MyString" }
  end
end
