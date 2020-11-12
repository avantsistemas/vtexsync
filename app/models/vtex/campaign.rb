module Vtex
  class Campaign < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order

    has_many :campaign_tags, dependent: :destroy
    has_many :marketing_tags, through: :campaign_tags

    sync_attributes :utmSource, :utmPartner, :utmMedium, :utmCampaign,
                    :utmiCampaign, :utmipage, :utmiPart, :coupon

    remap_attributes utmipage: :utmi_page
  end
end
