module Vtex
  module Sync
    class OrderJob < ApplicationJob
      queue_as :vtex_sync_order
      queue_with_priority JobPriority::HIGHEST

      # Tentativas máximas diante de rate limit (429) antes de desistir.
      MAX_RATE_LIMIT_ATTEMPTS = 8

      # Faixa de jitter (segundos) somada à espera ao reagendar por rate limit.
      # Sem ele, todos os jobs reagendados acordariam no mesmo instante em que o
      # cooldown expira e recriariam a rajada contra a API.
      RATE_LIMIT_JITTER = 0..15

      def perform(order_id)
        logger.tagged(order_id) { sync_order(order_id) }
      rescue Vtex::Api::RateLimitError => e
        reschedule_after_rate_limit(order_id, e)
      end

      private

      # Quando a VTEX nos limita (429) — seja porque esta requisição arrancou o
      # erro, seja porque o portão de cooldown já estava ativo — reagenda
      # respeitando o Retry-After em vez de bater de novo na API. Esgotadas as
      # tentativas, encerra de forma limpa notificando o Honeybadger.
      def reschedule_after_rate_limit(order_id, error)
        if executions >= MAX_RATE_LIMIT_ATTEMPTS
          logger.error("Desistindo da sincronização após esgotar retries de rate limit: #{error.message}")
          return Honeybadger.notify(error, context: { order_id: order_id })
        end

        wait = error.retry_after + rand(RATE_LIMIT_JITTER)
        logger.info("Rate limit da VTEX ativo; reagendando #{order_id} em #{wait}s (tentativa #{executions})")
        retry_job(wait: wait)
      end

      def sync_order(order_id)
        Vtex::Sync::Order.call(order_id)
      end
    end
  end
end
