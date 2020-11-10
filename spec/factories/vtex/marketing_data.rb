FactoryBot.define do
  factory :vtex_marketing_datum, class: 'Vtex::MarketingDatum' do
    order { nil }
    utm_source { "MyString" }
    utm_partner { "MyString" }
    utm_medium { "MyString" }
    utm_campaign { "MyString" }
    coupon { "MyString" }
  end
end
