module Vtex
  module Sync
    class Order
      module Dependents
        private

        def sync_dependents(vtex_order)
          sync_order_items(vtex_order)
        end

        def sync_order_items(vtex_order)
          Vtex::Sync::Product.sync_all(products_attributes)
        end

        def products_attributes
          order_attributes['itemMetadata']['Items']
        end
      end
    end
  end
end
