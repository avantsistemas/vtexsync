FactoryBot.define do
  factory :ibge_state, class: 'Ibge::State' do
    name { "MyString" }
    acronym { "MyString" }
    code { "MyString" }
  end
end
