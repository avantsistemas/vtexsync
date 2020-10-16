module Vtex
  module Sync
    class Order
      delegate :logger, to: Rails

      def initialize(api_client)
        @api_client = api_client
      end

      def sync(vtex_order_id)
        logger.tagged(vtex_order_id) do
          vtex_order = get_order_attributes_and_sync(vtex_order_id)
          log_what_will_be_done(vtex_order)

          if vtex_order.changed?
            # sync_dependencies(vtex_order)
            vtex_order.save!
          end
        end
      end

      private

      def get_order_attributes_and_sync(vtex_order_id)
        order_attributes = get_order_attributes(vtex_order_id)
        vtex_order = find_or_initialize_vtex_order(vtex_order_id)
        vtex_order.tap { vtex_order.sync_attributes(order_attributes) }
      end

      def get_order_attributes(vtex_order_id)
        @api_client.get_order(vtex_order_id)
      end

      def find_or_initialize_vtex_order(vtex_order_id)
        Vtex::Order.find_or_initialize_by vtex_code: vtex_order_id
      end

      def log_what_will_be_done(vtex_order)
        if vtex_order.new_record?
          attributes = vtex_order.attributes.except('id', 'created_at', 'updated_at')
          logger.info "Um novo pedido será cadastrado: #{attributes.as_json}"
        elsif vtex_order.changed?
          logger.info "O pedido será atualizado: #{vtex_order.changes.as_json}"
        else
          logger.debug 'O pedido já está sincronizado'
        end
      end
    end
  end
end
