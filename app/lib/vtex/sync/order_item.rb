module Vtex
  module Sync
    class OrderItem
      include Logger

      def initialize(order_item_attributes)
        @order_item_attributes = order_item_attributes
      end

      def sync(save: true)
        order_item = find_or_initialize_vtex_order_item
        order_item.sync_attributes(order_item_attributes)

        log_what_will_be_synced(order_item)

        order_item.save! if save && order_item.changed?
        order_item
      end

      def self.sync_all(order_items_attributes, save: true)
        order_items_attributes.map do |order_item_attributes|
          new(order_item_attributes).sync(save: save)
        end
      end

      private

      attr_reader :order_item_attributes

      def find_or_initialize_vtex_order_item
        Vtex::OrderItem.find_or_initialize_by vtex_code: vtex_unique_id
      end

      def vtex_unique_id
        order_item_attributes['uniqueId']
      end
    end
  end
end
