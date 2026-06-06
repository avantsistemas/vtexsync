module Vtex
  module Sync
    module Models
      class ProductCategory
        def initialize(category_attributes, vtex_product:)
          @category_attributes = category_attributes
          @vtex_product = vtex_product
        end

        def sync
          product_category = find_or_initialize_vtex_product_category

          Logger.log_what_will_be_synced(product_category)

          product_category.save! if product_category.changed?
          product_category
        end

        def self.sync_all(categories_attributes, vtex_product:)
          categories_attributes.map do |category_attributes|
            new(category_attributes, vtex_product: vtex_product).sync
          end
        end

        private

        attr_reader :category_attributes, :vtex_product

        def find_or_initialize_vtex_product_category
          category = Category.new(category_attributes).sync
          vtex_product.product_categories.find_or_initialize_by category: category
        end
      end
    end
  end
end
