# Aciona de hora em hora um check-in do Honeybadger para
# sinalizar que a fila de jobs está executando normalmente.
module Honeybadger
  class QueueHealthCheckJob < ApplicationJob
    queue_as :honeybadger_queue_health_check
    queue_with_priority JobPriority::LOWER

    after_perform { retry_job(wait: 1.hour) }

    def perform(check_in_id)
      logger.info "Notificando check-in #{check_in_id} do Honeybadger"
      Honeybadger.check_in(check_in_id)
    end
  end
end
