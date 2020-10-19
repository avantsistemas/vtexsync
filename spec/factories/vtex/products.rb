FactoryBot.define do
  factory :vtex_product, class: 'Vtex::Product' do
    vtex_code { "MyString" }
    name { "MyString" }
    sku_name { "MyString" }
    reference { "MyString" }
    ean { "MyString" }
    image_url { "MyString" }
    detail_url { "MyString" }
  end
end
