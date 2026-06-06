module Vtex
  module Sync
    module Models
      class Campaign
        include Dependents

        def initialize(campaign_attributes, vtex_order:)
          @campaign_attributes = campaign_attributes
          @vtex_order = vtex_order
        end

        def sync
          load_vtex_campaign

          sync_attributes

          Logger.log_what_will_be_synced(vtex_campaign)

          vtex_campaign.save! if vtex_campaign.changed?

          sync_dependents
          vtex_campaign
        end

        private

        attr_reader :campaign_attributes, :vtex_campaign, :vtex_order

        def load_vtex_campaign
          @vtex_campaign = vtex_order.campaign || vtex_order.build_campaign
        end

        def sync_attributes
          vtex_campaign.sync_attributes(campaign_attributes)
        end
      end
    end
  end
end
