module Vtex
  module Products
    # Drena produtos para enriquecimento de catálogo em ondas, espelhando o
    # +Orders::ResyncEnqueuer+. Por padrão pega só os pendentes (sem
    # +creation_date+); +all: true+ reprocessa todo o catálogo para capturar
    # mudanças em IsActive/IsKit.
    class EnrichmentEnqueuer
      # Tamanho de cada "onda" de jobs e intervalo entre ondas. Em vez de
      # despejar todos de uma vez (o que provocaria rate limit na VTEX e
      # encheria a fila de jobs que só ricocheteariam no portão de cooldown),
      # escalonamos o enfileiramento.
      DEFAULT_BATCH_SIZE = 100
      DEFAULT_BATCH_INTERVAL = 1.minute

      def self.call(limit: nil, all: false, batch_size: DEFAULT_BATCH_SIZE, batch_interval: DEFAULT_BATCH_INTERVAL)
        raise ArgumentError, 'batch_size deve ser positivo' unless batch_size.positive?
        raise ArgumentError, 'batch_interval deve ser positivo' unless batch_interval.positive?

        scope = all ? Vtex::Product.all : Vtex::Product.pending_enrichment
        scope = scope.limit(limit) if limit&.positive?

        # Se a VTEX já está em cooldown agora, adia a 1ª onda para depois da
        # janela conhecida. No-op quando não há cooldown ativo.
        initial_wait = ApiCooldown.retry_after_seconds(Vtex::Api::Client::COOLDOWN_KEY).seconds

        total = scope.count
        enqueued = 0
        scope.find_each.with_index do |product, index|
          wait = initial_wait + ((index / batch_size) * batch_interval)
          Vtex::Sync::ProductEnrichmentJob.set(priority: JobPriority::LOWEST, wait: wait).perform_later(product.id)
          enqueued += 1
        end

        { total: total, enqueued: enqueued }
      end
    end
  end
end
