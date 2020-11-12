module Vtex
  class CampaignTag < ApplicationRecord
    belongs_to :campaign
    belongs_to :marketing_tag
  end
end
