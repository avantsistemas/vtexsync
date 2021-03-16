FactoryBot.define do
  factory :ibge_district, class: 'Ibge::District' do
    city { nil }
    code { "MyString" }
    name { "MyString" }
  end
end
