module Vtex
  module Sync
    class Order
      module Dependents
        private

        def sync_dependents
          sync_products
          sync_order_items
        end

        def sync_products
          Vtex::Sync::Product.sync_all(products_attributes)
        end

        def sync_order_items
          order_items = Vtex::Sync::OrderItem.sync_all(order_items_attributes, save: false)
          vtex_order.items << order_items
        end

        def products_attributes
          order_attributes['itemMetadata']['Items']
        end

        def order_items_attributes
          order_attributes['items']
        end
      end
    end
  end
end
