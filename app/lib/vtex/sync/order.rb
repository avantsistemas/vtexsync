module Vtex
  module Sync
    class Order
      delegate :logger, to: Rails

      def initialize(order_attributes)
        @order_attributes = order_attributes
      end

      def sync
        logger.tagged(vtex_order_id) do
          find_or_initialize_vtex_order.tap do |vtex_order|
            vtex_order.sync_attributes(order_attributes)
            log_what_will_be_done(vtex_order)

            if vtex_order.changed?
              sync_dependencies(vtex_order)
              vtex_order.save!
            end
          end
        end
      end

      private

      attr_reader :order_attributes

      def vtex_order_id
        order_attributes['orderId']
      end

      def client_attributes
        order_attributes['clientProfileData']
      end

      def find_or_initialize_vtex_order
        Vtex::Order.find_or_initialize_by vtex_code: vtex_order_id
      end

      def sync_dependencies(vtex_order)
        sync_client(vtex_order)
      end

      def sync_client(vtex_order)
        client = Vtex::Sync::Client.new(client_attributes).sync
        vtex_order.client = client
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
