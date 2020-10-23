module Vtex
  module Sync
    module Models
      class Order
        module Dependents
          private

          def sync_dependents
            sync_products
            sync_order_items
          end

          def sync_products
            Product.sync_all(products_attributes)
          end

          def sync_order_items
            order_items = OrderItem.sync_all(order_items_attributes,
                                             vtex_order: vtex_order)
            destroy_not_synced_order_items(order_items)
          end

          def destroy_not_synced_order_items(synced_order_items)
            return if vtex_order.new_record?

            not_synced_order_items = vtex_order.items.where.not(id: synced_order_items)

            not_synced_order_items.each do |not_synced_order_item|
              Logger.log_model_will_be_destroyed(not_synced_order_item)
              not_synced_order_item.destroy!
            end
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
end
