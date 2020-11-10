FactoryBot.define do
  factory :vtex_benefit, class: 'Vtex::Benefit' do
    identifier { "MyString" }
    name { "MyString" }
    description { "MyString" }
    featured { false }
  end
end
