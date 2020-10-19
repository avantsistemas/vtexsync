module Vtex
  module Sync
    class Product
      include Logger

      def initialize(product_attributes)
        @product_attributes = product_attributes
      end

      def sync
        product = find_or_initialize_vtex_product
        product.sync_attributes(product_attributes)

        log_what_will_be_synced(product)

        product.save! if product.changed?
        product
      end

      def self.sync_all(products_attributes)
        products_attributes.map do |product_attributes|
          new(product_attributes).sync
        end
      end

      private

      attr_reader :product_attributes

      def vtex_id
        product_attributes['Id']
      end

      def find_or_initialize_vtex_product
        Vtex::Product.find_or_initialize_by vtex_code: vtex_id
      end
    end
  end
end
