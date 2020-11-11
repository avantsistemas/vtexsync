module Vtex
  class Campaign < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order

    sync_attributes :utmSource, :utmPartner, :utmMedium, :utmCampaign,
                    :utmiCampaign, :utmipage, :utmiPart, :coupon

    remap_attributes utmipage: :utmi_page
  end
end
