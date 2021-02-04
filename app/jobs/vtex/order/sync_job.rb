module Vtex
  class Order
    class SyncJob < ApplicationJob
      queue_as :vtex_order_sync

      def perform(order_id)
        logger.tagged(order_id) { sync_order(order_id) }
      end

      private

      def sync_order(order_id)
        order_attributes = api_client.get_order(order_id)
        Vtex::Sync::Models::Order.new(order_attributes).sync
      end

      def api_client
        Vtex::Api::Client.new(account_name: account_name,
                              environment: environment,
                              app_token: app_token,
                              app_key: app_key)
      end

      def account_name
        Rails.configuration.application.vtex[:bioextratus][:account_name]
      end

      def environment
        Rails.configuration.application.vtex[:bioextratus][:environment]
      end

      def app_token
        Rails.application.credentials.vtex[:bioextratus][:app_token]
      end

      def app_key
        Rails.application.credentials.vtex[:bioextratus][:app_key]
      end
    end
  end
end
