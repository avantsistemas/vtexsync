FactoryBot.define do
  factory :vtex_campaign_tag, class: 'Vtex::CampaignTag' do
    campaign { nil }
    tag { nil }
  end
end
