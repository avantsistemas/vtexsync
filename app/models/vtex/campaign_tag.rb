module Vtex
  class CampaignTag < ApplicationRecord
    has_paper_trail

    belongs_to :campaign
    belongs_to :marketing_tag
  end
end
