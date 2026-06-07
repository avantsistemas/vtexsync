module Vtex
  module Sync
    class ProductEnrichmentJob < ApplicationJob
      queue_as :vtex_sync_product_enrichment
      queue_with_priority JobPriority::LOWER

      # Tentativas máximas diante de rate limit (429) antes de desistir.
      MAX_RATE_LIMIT_ATTEMPTS = 8

      # Faixa de jitter (segundos) somada à espera ao reagendar por rate limit.
      # Sem ele, todos os jobs reagendados acordariam no mesmo instante em que o
      # cooldown expira e recriariam a rajada contra a API.
      RATE_LIMIT_JITTER = 0..15

      def perform(product_id)
        product = Vtex::Product.find_by(id: product_id)
        # O produto pode ter sido removido entre o enfileiramento e a execução.
        return unless product

        logger.tagged("sku:#{product.sku_code}") { Vtex::Sync::ProductEnrichment.call(product) }
      rescue Vtex::Api::RateLimitError => e
        reschedule_after_rate_limit(product_id, e)
      end

      private

      # Mesmo backoff do +OrderJob+: respeita o Retry-After da VTEX em vez de
      # bater de novo na API. Esgotadas as tentativas, encerra de forma limpa
      # notificando o Honeybadger.
      def reschedule_after_rate_limit(product_id, error)
        if executions >= MAX_RATE_LIMIT_ATTEMPTS
          logger.error("Desistindo do enriquecimento após esgotar retries de rate limit: #{error.message}")
          return Honeybadger.notify(error, context: { product_id: product_id })
        end

        wait = error.retry_after + rand(RATE_LIMIT_JITTER)
        logger.info("Rate limit da VTEX ativo; reagendando enriquecimento do produto #{product_id} " \
                    "em #{wait}s (tentativa #{executions})")
        retry_job(wait: wait)
      end
    end
  end
end
