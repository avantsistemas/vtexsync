module Vtex
  module Sync
    module Models
      class Campaign
        module Dependents
          private

          def sync_dependents
            sync_campaign_tags
          end

          def sync_campaign_tags
            marketing_tag_names = campaign_attributes['marketingTags']

            campaign_tags = CampaignTag.sync_all(marketing_tag_names, vtex_campaign: vtex_campaign)

            destroy_not_synced(campaign_tags, scope: vtex_campaign.campaign_tags)
          end

          def destroy_not_synced(synced_models, scope:)
            not_synced_models = scope.where.not(id: synced_models)

            not_synced_models.each do |not_synced_model|
              Logger.log_model_will_be_destroyed(not_synced_model)
              not_synced_model.destroy!
            end
          end
        end
      end
    end
  end
end
