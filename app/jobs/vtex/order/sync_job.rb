module Vtex
  class Order
    class SyncJob < ApplicationJob
      queue_as :vtex_order_sync
      queue_with_priority JobPriority::HIGHEST

      # Quando a VTEX nos limita (429), reagenda com backoff exponencial em
      # vez de bater de novo na API imediatamente. O bloco no esgotamento
      # encerra de forma limpa, evitando que a exceção escape para o retry
      # nativo do Delayed Job (max_attempts).
      retry_on Vtex::Api::RateLimitError, wait: :polynomially_longer, attempts: 8 do |job, error|
        job.logger.error("Desistindo da sincronização após esgotar retries de rate limit: #{error.message}")
        Honeybadger.notify(error, context: { order_id: job.arguments.first })
      end

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
