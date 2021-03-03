FactoryBot.define do
  factory :ibge_city, class: 'Ibge::City' do
    state { nil }
    name { "MyString" }
    code { "MyString" }
  end
end
