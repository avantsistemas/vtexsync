module Vtex
  module Sync
    module Models
      class OrderTotal
        def initialize(order_total_attributes, vtex_order:)
          @order_total_attributes = order_total_attributes
          @vtex_order = vtex_order
        end

        def sync
          order_total = find_or_initialize_vtex_order_total
          order_total.sync_attributes(order_total_attributes)

          Logger.log_what_will_be_synced(order_total)

          order_total.save! if order_total.changed?
          order_total
        end

        def self.sync_all(order_totals_attributes, vtex_order:)
          order_totals_attributes.map do |order_total_attributes|
            new(order_total_attributes, vtex_order: vtex_order).sync
          end
        end

        private

        attr_reader :order_total_attributes, :vtex_order

        def find_or_initialize_vtex_order_total
          total = Total.new(order_total_attributes).sync
          vtex_order.totals.find_or_initialize_by total: total
        end
      end
    end
  end
end
