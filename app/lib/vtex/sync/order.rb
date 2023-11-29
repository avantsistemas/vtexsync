module Vtex
  module Sync
    class Order
      delegate :logger, to: Rails

      def initialize(api_client)
        @api_client = api_client
      end

      def sync(order_id)
        logger.info "Sincronizando pedido #{order_id}"
        order_attributes = @api_client.get_order(order_id)
        Vtex::Sync::Models::Order.new(order_attributes).sync
      end
    end
  end
end
