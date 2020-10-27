module Vtex
  module Sync
    module Models
      class OrderItem
        module Dependencies
          private

          def sync_dependencies
            sync_product
          end

          def sync_product
            product_attributes = order_item_attributes
            vtex_product = Product.new(product_attributes).sync
            vtex_order_item.product = vtex_product
          end
        end
      end
    end
  end
end
