module Vtex
  module Orders
    class ResyncEnqueuer
      # Tamanho de cada "onda" de jobs e intervalo entre ondas. Em vez de
      # despejar todos os jobs de uma vez (o que provocaria rate limit na VTEX e
      # encheria a fila de jobs que só ricocheteariam no portão de cooldown),
      # escalonamos o enfileiramento: cada onda subsequente roda BATCH_INTERVAL
      # depois da anterior, suavizando a carga contra a API.
      DEFAULT_BATCH_SIZE = 100
      DEFAULT_BATCH_INTERVAL = 1.minute

      def self.call(limit: nil, batch_size: DEFAULT_BATCH_SIZE, batch_interval: DEFAULT_BATCH_INTERVAL)
        raise ArgumentError, 'batch_size deve ser positivo' unless batch_size.positive?
        raise ArgumentError, 'batch_interval deve ser positivo' unless batch_interval.positive?

        pending = Vtex::Order.pending_resync
        pending = pending.limit(limit) if limit&.positive?

        # Se a VTEX já está em cooldown agora, adia a 1ª onda para depois da
        # janela conhecida em vez de acordá-la só para ricochetear no portão.
        # No-op quando não há cooldown ativo (retry_after_seconds == 0).
        initial_wait = ApiCooldown.retry_after_seconds(Vtex::Api::Client::COOLDOWN_KEY).seconds

        total = pending.count
        enqueued = 0
        pending.find_each.with_index do |order, index|
          wait = initial_wait + ((index / batch_size) * batch_interval)
          Vtex::Order::SyncJob.set(priority: JobPriority::LOWEST, wait: wait).perform_later(order.order_code)
          enqueued += 1
        end

        { total: total, enqueued: enqueued }
      end
    end
  end
end
