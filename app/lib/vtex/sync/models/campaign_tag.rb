module Vtex
  module Sync
    module Models
      class CampaignTag
        def initialize(marketing_tag_name, vtex_campaign:)
          @marketing_tag_name = marketing_tag_name
          @vtex_campaign = vtex_campaign
        end

        def sync
          campaign_tag = find_or_initialize_vtex_campaign_tag

          Logger.log_what_will_be_synced(campaign_tag)

          campaign_tag.save! if campaign_tag.changed?
          campaign_tag
        end

        def self.sync_all(categories_attributes, vtex_campaign:)
          categories_attributes.map do |marketing_tag_name|
            new(marketing_tag_name, vtex_campaign: vtex_campaign).sync
          end
        end

        private

        attr_reader :marketing_tag_name, :vtex_campaign

        def find_or_initialize_vtex_campaign_tag
          marketing_tag = Vtex::MarketingTag.find_or_create_by! name: marketing_tag_name
          vtex_campaign.campaign_tags.find_or_initialize_by marketing_tag: marketing_tag
        end
      end
    end
  end
end
