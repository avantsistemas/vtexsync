FactoryBot.define do
  factory :vtex_payment_system, class: 'Vtex::PaymentSystem' do
    identifier { "MyString" }
    name { "MyString" }
    group { "MyString" }
  end
end
