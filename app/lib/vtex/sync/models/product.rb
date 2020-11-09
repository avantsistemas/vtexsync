module Vtex
  module Sync
    module Models
      class Product
        include Dependencies
        include Dependents

        def initialize(order_item_attributes)
          @order_item_attributes = order_item_attributes
        end

        def sync
          load_vtex_product

          sync_dependencies
          sync_dependents
          sync_attributes

          Logger.log_what_will_be_synced(vtex_product)

          vtex_product.save! if vtex_product.changed?
          vtex_product
        end

        private

        attr_reader :order_item_attributes, :vtex_product

        def load_vtex_product
          attribute_ref_id = order_item_attributes['refId']
          @vtex_product = Vtex::Product.find_or_initialize_by identifier: attribute_ref_id
        end

        def sync_attributes
          vtex_product.sync_attributes(order_item_attributes)
        end
      end
    end
  end
end
