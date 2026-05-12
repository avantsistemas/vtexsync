module Vtex
  class Order
    class SyncJob < ApplicationJob
      queue_as :vtex_order_sync
      queue_with_priority JobPriority::HIGHEST

      def perform(order_id)
        logger.tagged(order_id) { sync_order(order_id) }
      end

      private

      def sync_order(order_id)
        order_attributes = api_client.get_order(order_id)
        synced_order = Vtex::Sync::Models::Order.new(order_attributes).sync
        clear_resync_flag(synced_order)
      end

      def clear_resync_flag(synced_order)
        return if synced_order.resync_requested_at.nil?

        synced_order.update_columns(resync_requested_at: nil, resync_reason: nil)
      end

      def api_client
        Vtex::Api::Client.new(account_name: Rails.configuration.application.vtex[:account_name],
                              environment: Rails.configuration.application.vtex[:environment],
                              app_token: Rails.application.credentials.vtex[:app_token],
                              app_key: Rails.application.credentials.vtex[:app_key])
      end
    end
  end
end
