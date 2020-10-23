module Vtex
  module Sync
    module Models
      class Product
        def initialize(product_attributes)
          @product_attributes = product_attributes
        end

        def sync
          product = find_or_initialize_vtex_product
          product.sync_attributes(product_attributes)

          Logger.log_what_will_be_synced(product)

          product.save! if product.changed?
          product
        end

        def self.sync_all(products_attributes)
          products_attributes.each do |product_attributes|
            new(product_attributes).sync
          end
        end

        private

        attr_reader :product_attributes

        def find_or_initialize_vtex_product
          Vtex::Product.find_or_initialize_by identifier: attribute_ref_id
        end

        def attribute_ref_id
          product_attributes['RefId']
        end
      end
    end
  end
end
