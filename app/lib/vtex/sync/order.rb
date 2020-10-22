module Vtex
  module Sync
    class Order
      include Dependencies
      include Dependents
      include Logger

      def initialize(order_attributes)
        @order_attributes = order_attributes
      end

      def sync(save: true)
        load_vtex_order

        sync_dependencies
        sync_dependents
        sync_attributes

        log_what_will_be_synced(vtex_order)

        vtex_order.save! if save && vtex_order.changed?
        vtex_order
      end

      private

      attr_reader :order_attributes, :vtex_order

      def load_vtex_order
        @vtex_order = Vtex::Order.find_or_initialize_by vtex_code: vtex_order_id
      end

      def vtex_order_id
        order_attributes['orderId']
      end

      def sync_attributes
        vtex_order.sync_attributes(order_attributes)
      end
    end
  end
end
