FactoryBot.define do
  factory :vtex_client, class: 'Vtex::Client' do
    vtex_code { "MyString" }
    first_name { "MyString" }
    last_name { "MyString" }
    document_type { "MyString" }
    document { "MyString" }
    phone { "MyString" }
  end
end
