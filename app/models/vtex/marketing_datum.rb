module Vtex
  class MarketingDatum < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order

    sync_attributes :utmSource, :utmPartner, :utmMedium, :utmCampaign, :coupon
  end
end
