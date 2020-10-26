module Vtex
  module Sync
    module Models
      class Product
        def initialize(order_item_attributes)
          @order_item_attributes = order_item_attributes
        end

        def sync
          product = find_or_initialize_vtex_product
          product.sync_attributes(order_item_attributes)

          Logger.log_what_will_be_synced(product)

          product.save! if product.changed?
          product
        end

        def self.sync_all(order_items_attributes)
          order_items_attributes.map do |order_item_attributes|
            new(order_item_attributes).sync
          end
        end

        private

        attr_reader :order_item_attributes

        def find_or_initialize_vtex_product
          Vtex::Product.find_or_initialize_by identifier: attribute_ref_id
        end

        def attribute_ref_id
          order_item_attributes['refId']
        end
      end
    end
  end
end
