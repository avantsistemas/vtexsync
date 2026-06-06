module Vtex
  module Sync
    module Models
      class Product
        include Identifiable
        include Dependencies
        include Dependents

        def initialize(order_item_attributes)
          @order_item_attributes = order_item_attributes
        end

        def sync
          load_vtex_product

          sync_dependencies
          sync_attributes

          Logger.log_what_will_be_synced(vtex_product)

          vtex_product.save! if vtex_product.changed?

          sync_dependents
          vtex_product
        end

        private

        attr_reader :order_item_attributes, :vtex_product

        def load_vtex_product
          @vtex_product = find_or_initialize_record
        end

        def model_class
          Vtex::Product
        end

        def fingerprint
          order_item_attributes['refId']
        end

        def sync_attributes
          vtex_product.sync_attributes(order_item_attributes)
        end
      end
    end
  end
end
