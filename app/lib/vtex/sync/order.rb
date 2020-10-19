module Vtex
  module Sync
    class Order
      include Dependencies
      include Dependents
      include Logger

      def initialize(order_attributes)
        @order_attributes = order_attributes
      end

      def sync
        logger.tagged(vtex_order_id) do
          vtex_order = find_or_initialize_vtex_order

          sync_dependencies(vtex_order)
          sync_dependents(vtex_order)
          sync_attributes(vtex_order)

          log_what_will_be_synced(vtex_order)

          vtex_order.save! if vtex_order.changed?
          vtex_order
        end
      end

      private

      attr_reader :order_attributes

      def vtex_order_id
        order_attributes['orderId']
      end

      def sync_attributes(vtex_order)
        vtex_order.sync_attributes(order_attributes)
      end

      def find_or_initialize_vtex_order
        Vtex::Order.find_or_initialize_by vtex_code: vtex_order_id
      end
    end
  end
end
