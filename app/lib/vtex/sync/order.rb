module Vtex
  module Sync
    class Order
      delegate :logger, to: Rails

      # Conveniência para chamadas avulsas (rake, job): constrói o client. No
      # batch, prefira a forma de instância para reaproveitar o mesmo client
      # (conexão e estado de cooldown) entre os pedidos.
      def self.call(order_id, api_client: Vtex::Api::Client.build)
        new(api_client).call(order_id)
      end

      def initialize(api_client)
        @api_client = api_client
      end

      def call(order_id)
        logger.info "Sincronizando pedido #{order_id}"

        # Fetch fora da transação: nunca manter uma transação de banco aberta
        # durante a chamada de rede, que pode demorar ou estourar rate limit.
        order_attributes = @api_client.get_order(order_id)

        # Unidade atômica: o pedido sincronizado por inteiro mais a baixa dos
        # requests de resync. Se qualquer dependente falhar, nada é gravado e os
        # requests seguem em aberto para um novo enfileiramento.
        ActiveRecord::Base.transaction do
          order = Vtex::Sync::Models::Order.new(order_attributes).sync
          complete_resync_requests(order)
          order
        end
      end

      private

      # Fecha os requests em aberto preenchendo completed_at (sem apagar o
      # motivo), preservando o histórico das re-sincronizações.
      def complete_resync_requests(order)
        now = Time.current
        order.resync_requests.pending.update_all(completed_at: now, updated_at: now)
      end
    end
  end
end
