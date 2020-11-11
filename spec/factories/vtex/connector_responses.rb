FactoryBot.define do
  factory :vtex_connector_response, class: 'Vtex::ConnectorResponse' do
    payment { nil }
    tid { "MyString" }
    auth_id { "MyString" }
    nsu { "MyString" }
    network { "MyString" }
    first_digits { "MyString" }
    last_digits { "MyString" }
    acquirer { "MyString" }
    message { "MyString" }
    return_code { "MyString" }
  end
end
