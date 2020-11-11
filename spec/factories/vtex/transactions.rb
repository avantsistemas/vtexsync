FactoryBot.define do
  factory :vtex_transaction, class: 'Vtex::Transaction' do
    order { nil }
    identifier { "MyString" }
    merchant_name { "MyString" }
    active { false }
  end
end
