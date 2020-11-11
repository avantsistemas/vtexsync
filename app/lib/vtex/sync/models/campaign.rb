module Vtex
  module Sync
    module Models
      class Campaign
        def initialize(campaign_attributes, vtex_order:)
          @campaign_attributes = campaign_attributes
          @vtex_order = vtex_order
        end

        def sync
          campaign = find_or_initialize_vtex_campaign
          campaign.sync_attributes(campaign_attributes)

          Logger.log_what_will_be_synced(campaign)

          campaign.save! if vtex_order.persisted? && campaign.changed?
          campaign
        end

        private

        attr_reader :campaign_attributes, :vtex_order

        def find_or_initialize_vtex_campaign
          vtex_order.campaign || vtex_order.build_campaign
        end
      end
    end
  end
end
