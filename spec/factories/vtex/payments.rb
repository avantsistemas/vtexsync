FactoryBot.define do
  factory :vtex_payment, class: 'Vtex::Payment' do
    transaction { nil }
    identifier { "MyString" }
    payment_system_name { "MyString" }
    value { "9.99" }
    installments { 1 }
    group { "MyString" }
  end
end
