FactoryBot.define do
  factory :vtex_product_category, class: 'Vtex::ProductCategory' do
    product { nil }
    category { nil }
  end
end
