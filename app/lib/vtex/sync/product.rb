module Vtex
  module Sync
    class Product
      include Logger

      def initialize(product_attributes)
        @product_attributes = product_attributes
      end

      def sync(save: true)
        product = find_or_initialize_vtex_product
        product.sync_attributes(product_attributes)

        log_what_will_be_synced(product)

        product.save! if save && product.changed?
        product
      end

      def self.sync_all(products_attributes, save: true)
        products_attributes.map do |product_attributes|
          new(product_attributes).sync(save: save)
        end
      end

      private

      attr_reader :product_attributes

      def find_or_initialize_vtex_product
        Vtex::Product.find_or_initialize_by vtex_code: vtex_product_id
      end

      def vtex_product_id
        product_attributes['ProductId']
      end
    end
  end
end
